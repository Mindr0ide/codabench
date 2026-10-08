<dashboard>
    <div class="ui container fluid dashboard-container" style="max-width: 1400px; padding: 0 20px;">
        <div class="ui stackable grid">
            <div class="sixteen wide column">
                <h2 class="ui header">
                    <i class="chart pie icon"></i>
                    <div class="content">
                        Competitions Dashboard
                        <div class="sub header">Analyze trends, organizers, and domains across Codabench</div>
                    </div>
                </h2>
            </div>
        </div>

        <div class="ui divider"></div>

        <div class="ui active inverted dimmer" if="{ loading }">
            <div class="ui large text loader">Fetching data...</div>
        </div>

        <div class="ui stackable grid" show="{ !loading }">
            <div class="four wide column">
                <dashboard-filters p="{ this }"></dashboard-filters>
            </div>

            <div class="twelve wide column">
                <dashboard-charts p="{ this }"></dashboard-charts>
                

                <dashboard-table p="{ this }"></dashboard-table>
            </div>
        </div>
    </div>

    <script>
        var self = this;
        self.isAdmin = typeof CODALAB !== "undefined" && CODALAB.state && CODALAB.state.user && (CODALAB.state.user.is_superuser || CODALAB.state.user.is_staff);

        self.loading = true;
        self.dataSource = "api";
        self.allCompetitions = [];
        self.filteredCompetitions = [];
        self.pagedCompetitions = [];
        self.pageSize = 15;
        self.currentPage = 1;
        self.totalPages = 1;

        self.availableCategories = [];
        self.categoryFilters = [];
        self.chartCards = [];
        self.categoryTagsCounts = {};
        
        self.kpis = {
            distinctOrganizers: 0,
            participants: 0,
            submissions: 0
        };

        // Filter and sort state
        self.state = {
            search: "",
            searchField: "both",
            mode: "or",
            visibility: "public",
            type: "all",
            selectedTags: {},
            openCats: {},
            sortKey: "id",
            sortDir: 1,
            startDate: null,
            endDate: null
        };

        self.charts = {};
        self.search_timer = null;

        var PALETTE = ["#2185d0", "#00b5ad", "#21ba45", "#fbbd08", "#f2711c", "#db2828", "#a333c8", "#e03997", "#767676"];

        self.on('mount', function () {
            self.fetchData();
        });

        // Fetch all competitions using recursive pagination to enable client-side filtering
        self.fetchData = function () {
            self.loading = true;
            self.update();

            var allResults = [];
            var apiUrl = (typeof URLS !== "undefined" && URLS.API) ? URLS.API + "competitions/?page_size=1000" : "/api/competitions/?page_size=1000";
            if (self.isAdmin) {
                apiUrl += "&visibility=all";
            } else {
                apiUrl += "&visibility=public";
            }

            function fetchPage(url) {
                CODALAB.api.request('GET', url)
                    .done(function (resp) {
                        var results = (resp && resp.results) ? resp.results : [];
                        allResults = allResults.concat(results);
                        
                        if (resp && resp.next) {
                            var parser = document.createElement('a');
                            parser.href = resp.next;
                            var relativeUrl = parser.pathname + parser.search;
                            fetchPage(relativeUrl);
                        } else {
                            self.allCompetitions = self.classifyCompetitions(allResults);
                            self.dataSource = "api";
                            self.onDataLoaded();
                            // Init Semantic UI accordion and bind state to preserve open/close across Riot updates
                            setTimeout(function() {
                                $('.category-accordion').accordion({
                                    exclusive: false,
                                    onOpen: function() {
                                        var catName = $(this).data('catname');
                                        if (catName) self.state.openCats[catName] = true;
                                    },
                                    onClose: function() {
                                        var catName = $(this).data('catname');
                                        if (catName) self.state.openCats[catName] = false;
                                    }
                                });
                            }, 50);
                        }
                    })
                    .fail(function () {
                        if (typeof toastr !== "undefined") toastr.error("Failed to load competitions data");
                        if (allResults.length > 0) {
                            self.allCompetitions = self.classifyCompetitions(allResults);
                        } else {
                            self.allCompetitions = [];
                        }
                        self.dataSource = "api";
                        self.onDataLoaded();
                    });
            }

            fetchPage(apiUrl);
        };

        self.onDataLoaded = function () {
            self.loading = false;
            self.applyFilters();
            self.update();
            setTimeout(function () {
                self.initCalendars();
                self.initOrUpdateCharts();
            }, 50);
        };

        // Extract categories and tags from raw API response to build filter menus
        self.classifyCompetitions = function (list) {
            self.globalCategoryTags = {};
            
            var mapped = list.map(function (item) {
                var compUrl = (typeof URLS !== "undefined" && URLS.COMPETITION_DETAIL) ? URLS.COMPETITION_DETAIL(item.id) : ("/competitions/" + item.id + "/");
                var comp = {
                    id: item.id,
                    title: item.title,
                    organizer: item.created_by || item.owner_display_name || "organizer",
                    url: compUrl,
                    published: item.published,
                    competition_type: item.competition_type || "competition",
                    participants_count: item.participants_count || 0,
                    submissions_count: item.submissions_count || 0,
                    created_when: item.created_when,
                    tagsByCategory: {}
                };

                if (item.tags && Array.isArray(item.tags)) {
                    item.tags.forEach(function(tag) {
                        var cat = tag.category || "Other";
                        if (!self.globalCategoryTags[cat]) self.globalCategoryTags[cat] = {};
                        self.globalCategoryTags[cat][tag.name] = true;
                        
                        if (!comp.tagsByCategory[cat]) comp.tagsByCategory[cat] = [];
                        comp.tagsByCategory[cat].push(tag.name);
                    });
                }
                return comp;
            });

            self.availableCategories = Object.keys(self.globalCategoryTags).sort();
            
            self.state.selectedTags = {};
            self.chartCards = [];
            
            // Re-bind charts, using refs array for dynamically rendered canvas elements
            self.availableCategories.forEach(function(cat, idx) {
                self.state.selectedTags[cat] = {};
                self.chartCards.push({
                    catName: cat,
                    id: "chart_cat_" + idx
                });
            });

            self.kpis.categoriesPresent = self.availableCategories.length;

            mapped.forEach(function(comp) {
                comp.categoryColumns = self.availableCategories.map(function(cat) {
                    return (comp.tagsByCategory[cat] || []).join(", ");
                });
            });

            return mapped;
        };

        self.toggleTagHandler = function (e) {
            var catName = e.target.getAttribute('data-cat');
            var tagName = e.target.getAttribute('data-tag');
            var checked = e.target.checked;

            if (!self.state.selectedTags[catName]) {
                self.state.selectedTags[catName] = {};
            }
            if (checked) {
                self.state.selectedTags[catName][tagName] = true;
            } else {
                delete self.state.selectedTags[catName][tagName];
            }
            self.currentPage = 1;
            self.applyFilters();
            self.update();
            setTimeout(self.initOrUpdateCharts, 50);
        };

        self.resetFilters = function () {
            self.state.search = "";
            self.state.mode = "or";
            self.state.selectedTags = {};
            if (self.refs.searchInput) self.refs.searchInput.value = "";
            if (self.refs.start_calendar) $(self.refs.start_calendar).calendar('clear');
            if (self.refs.end_calendar) $(self.refs.end_calendar).calendar('clear');
            self.state.startDate = null;
            self.state.endDate = null;
            self.currentPage = 1;
            self.applyFilters();
            self.update();
            setTimeout(self.initOrUpdateCharts, 50);
        };

        self.initCalendars = function () {
            var general_calendar_options = {
                type: 'date',
                formatter: {
                   date: function (date, settings) {
                       if (!date) return '';
                       var d = date.getDate(), m = date.getMonth() + 1, y = date.getFullYear();
                       return y + '-' + (m<=9 ? '0' + m : m) + '-' + (d<=9 ? '0' + d : d);
                   }
                }
            };

            var start_options = Object.assign({}, general_calendar_options, {
                endCalendar: $(self.refs.end_calendar),
                onChange: function(date, text) {
                    self.state.startDate = date ? new Date(date) : null;
                    self.currentPage = 1;
                    self.applyFilters();
                    self.update();
                    setTimeout(self.initOrUpdateCharts, 50);
                }
            });

            var end_options = Object.assign({}, general_calendar_options, {
                startCalendar: $(self.refs.start_calendar),
                onChange: function(date, text) {
                    self.state.endDate = date ? new Date(date) : null;
                    self.currentPage = 1;
                    self.applyFilters();
                    self.update();
                    setTimeout(self.initOrUpdateCharts, 50);
                }
            });

            $(self.refs.start_calendar).calendar(start_options);
            $(self.refs.end_calendar).calendar(end_options);
        };

        self.updateSearch = function (e) {
            self.state.search = e.target.value.toLowerCase();
            
            if (self.search_timer) {
                clearTimeout(self.search_timer);
            }
            
            self.search_timer = setTimeout(function() {
                self.currentPage = 1;
                self.applyFilters();
                self.update();
                setTimeout(self.initOrUpdateCharts, 50);
            }, 400); // Debounce to prevent UI freeze while typing
        };

        self.updateSearchField = function (e) {
            self.state.searchField = e.target.value;
            self.currentPage = 1;
            self.applyFilters();
            self.update();
            setTimeout(self.initOrUpdateCharts, 50);
        };

        self.setModeOr = function () {
            self.state.mode = 'or';
            self.currentPage = 1;
            self.applyFilters();
            self.update();
            setTimeout(self.initOrUpdateCharts, 50);
        };

        self.setVisibility = function(val) {
            self.state.visibility = val;
            self.currentPage = 1;
            self.applyFilters();
            self.update();
            setTimeout(self.initOrUpdateCharts, 50);
        };

        self.setType = function(val) {
            self.state.type = val;
            self.currentPage = 1;
            self.applyFilters();
            self.update();
            setTimeout(self.initOrUpdateCharts, 50);
        };

        self.setModeAnd = function () {
            self.state.mode = 'and';
            self.currentPage = 1;
            self.applyFilters();
            self.update();
            setTimeout(self.initOrUpdateCharts, 50);
        };

        self.sortTableId = function () { self.sortTable('id'); };
        self.sortTableTitle = function () { self.sortTable('title'); };
        self.sortTableOrg = function () { self.sortTable('organizer'); };

        self.sortTable = function (key) {
            if (self.state.sortKey === key) {
                self.state.sortDir *= -1;
            } else {
                self.state.sortKey = key;
                self.state.sortDir = 1;
            }
            self.applyFilters();
            self.update();
        };

        self.changePagePrev = function () {
            var p = self.currentPage - 1;
            if (p >= 1 && p <= self.totalPages) {
                self.currentPage = p;
                self.updatePagination();
            }
        };

        self.changePageNext = function () {
            var p = self.currentPage + 1;
            if (p >= 1 && p <= self.totalPages) {
                self.currentPage = p;
                self.updatePagination();
            }
        };

        // Check if competition tags match selected filters (AND/OR mode)
        function tagMatch(compTagsByCat, selectedTagsByCat) {
            var hasAnySelection = false;
            var cats = Object.keys(selectedTagsByCat);
            for (var i = 0; i < cats.length; i++) {
                if (Object.keys(selectedTagsByCat[cats[i]]).length > 0) {
                    hasAnySelection = true;
                }
            }
            if (!hasAnySelection) return true;

            if (self.state.mode === "and") {
                for (var i = 0; i < cats.length; i++) {
                    var cat = cats[i];
                    var selected = Object.keys(selectedTagsByCat[cat]);
                    var compTags = compTagsByCat[cat] || [];
                    var allMatch = true;
                    selected.forEach(function(it) {
                        if (compTags.indexOf(it) === -1) allMatch = false;
                    });
                    if (!allMatch) return false;
                }
                return true;
            } else {
                for (var i = 0; i < cats.length; i++) {
                    var cat = cats[i];
                    var selected = Object.keys(selectedTagsByCat[cat]);
                    var compTags = compTagsByCat[cat] || [];
                    var anyMatch = false;
                    selected.forEach(function(it) {
                        if (compTags.indexOf(it) !== -1) anyMatch = true;
                    });
                    if (anyMatch) return true;
                }
                return false;
            }
        }

        // Main filter pipeline: Text search -> Visibility -> Tag matching -> Rebuild UI counts
        self.applyFilters = function () {
            var s = self.state.search;
            self.filteredCompetitions = self.allCompetitions.filter(function (c) {
                if (self.isAdmin) {
                    if (self.state.visibility === 'public' && !c.published) return false;
                    if (self.state.visibility === 'private' && c.published) return false;
                }
                if (self.state.type !== 'all' && c.competition_type !== self.state.type) {
                    return false;
                }
                
                if (self.state.startDate || self.state.endDate) {
                    var compDate = c.created_when ? new Date(c.created_when) : null;
                    if (!compDate) return false;
                    
                    if (self.state.startDate && compDate < self.state.startDate) return false;
                    
                    // We must include the entire end date up to midnight
                    if (self.state.endDate) {
                        var endLimit = new Date(self.state.endDate);
                        endLimit.setHours(23, 59, 59, 999);
                        if (compDate > endLimit) return false;
                    }
                }
                if (s) {
                    var matchTitle = c.title.toLowerCase().indexOf(s) !== -1;
                    var matchOrg = c.organizer.toLowerCase().indexOf(s) !== -1;
                    
                    if (self.state.searchField === 'title' && !matchTitle) return false;
                    if (self.state.searchField === 'organizer' && !matchOrg) return false;
                    if (self.state.searchField === 'both' && !matchTitle && !matchOrg) return false;
                }
                return tagMatch(c.tagsByCategory, self.state.selectedTags);
            });

            self.filteredCompetitions.sort(function (a, b) {
                var vA = a[self.state.sortKey];
                var vB = b[self.state.sortKey];
                if (typeof vA === "string") vA = vA.toLowerCase();
                if (typeof vB === "string") vB = vB.toLowerCase();
                if (vA < vB) return -1 * self.state.sortDir;
                if (vA > vB) return 1 * self.state.sortDir;
                return 0;
            });

            var orgs = {};
            self.categoryTagsCounts = {};
            var totalTags = 0;
            var totalParticipants = 0;
            var totalSubmissions = 0;
            
            self.filteredCompetitions.forEach(function (c) {
                orgs[c.organizer] = true;
                totalParticipants += (c.participants_count || 0);
                totalSubmissions += (c.submissions_count || 0);
                
                Object.keys(c.tagsByCategory).forEach(function(cat) {
                    if (!self.categoryTagsCounts[cat]) self.categoryTagsCounts[cat] = {};
                    c.tagsByCategory[cat].forEach(function(t) {
                        totalTags++;
                        self.categoryTagsCounts[cat][t] = (self.categoryTagsCounts[cat][t] || 0) + 1;
                    });
                });
            });
            
            self.kpis.distinctOrganizers = Object.keys(orgs).length;
            self.kpis.tagsAssigned = totalTags;
            self.kpis.participants = totalParticipants;
            self.kpis.submissions = totalSubmissions;

            self.categoryFilters = [];
            self.availableCategories.forEach(function(cat) {
                var counts = self.categoryTagsCounts[cat] || {};
                var allTagsForCat = Object.keys(self.globalCategoryTags[cat]);
                
                var tagsArr = allTagsForCat.map(function(k) {
                    var isChecked = false;
                    if (self.state.selectedTags[cat] && self.state.selectedTags[cat][k]) {
                        isChecked = true;
                    }
                    return { name: k, count: (counts[k] || 0), checked: isChecked };
                });
                
                tagsArr.sort(function (a, b) { 
                    if (a.checked !== b.checked) return a.checked ? -1 : 1;
                    if (b.count !== a.count) return b.count - a.count; 
                    return a.name.localeCompare(b.name);
                });
                
                self.categoryFilters.push({
                    name: cat,
                    tags: tagsArr
                });
            });

            self.totalPages = Math.max(1, Math.ceil(self.filteredCompetitions.length / self.pageSize));
            self.currentPage = Math.min(self.currentPage, self.totalPages);
            self.updatePagination();
            setTimeout(function() {
                $('.category-accordion').accordion({
                    exclusive: false,
                    onOpen: function() {
                        var catName = $(this).data('catname');
                        if (catName) self.state.openCats[catName] = true;
                    },
                    onClose: function() {
                        var catName = $(this).data('catname');
                        if (catName) self.state.openCats[catName] = false;
                    }
                });
            }, 50);
        };

        self.updatePagination = function () {
            var start = (self.currentPage - 1) * self.pageSize;
            self.pagedCompetitions = self.filteredCompetitions.slice(start, start + self.pageSize);
        };

        function countOrgs(list, limit) {
            var map = {};
            list.forEach(function (c) {
                map[c.organizer] = (map[c.organizer] || 0) + 1;
            });
            var entries = Object.keys(map).map(function (k) { return [k, map[k]]; });
            entries.sort(function (a, b) { return b[1] - a[1]; });
            return entries.slice(0, limit);
        }

        // Cycle through Bar, Doughnut, and Vertical Bar charts for tag categories
        self.initOrUpdateCharts = function () {
            var rows = self.filteredCompetitions;
            
            var oPairs = countOrgs(rows, 10);
            self.renderHorizontalBar("chOrgs", oPairs, "#21ba45");

            var cPairs = rows.map(function(c) { 
                var shortTitle = c.title.length > 25 ? c.title.substring(0, 25) + '...' : c.title;
                return [shortTitle, c.participants_count || 0]; 
            });
            cPairs.sort(function(a, b) { return b[1] - a[1]; });
            cPairs = cPairs.slice(0, 10);
            self.renderHorizontalBar("chComps", cPairs, "#fbbd08");

            // Re-bind charts, using refs array for dynamically rendered canvas elements
            self.availableCategories.forEach(function(cat, idx) {
                var counts = self.categoryTagsCounts[cat] || {};
                var pairs = Object.keys(counts).map(function(k) { return [k, counts[k]]; });
                pairs.sort(function(a, b) { return b[1] - a[1]; });
                pairs = pairs.slice(0, 15);
                
                var canvasId = "chart_cat_" + idx;
                
                var el = null;
                if (self.refs.dynamicCharts) {
                    if (Array.isArray(self.refs.dynamicCharts)) {
                        el = self.refs.dynamicCharts[idx];
                    } else if (idx === 0) {
                        el = self.refs.dynamicCharts;
                    }
                }
                var color = PALETTE[idx % PALETTE.length];
                
                if (el) {
                    if (idx % 3 === 0) {
                        self.renderHorizontalBarId(canvasId, pairs, color, el);
                    } else if (idx % 3 === 1) {
                        self.renderDoughnutId(canvasId, pairs, el);
                    } else {
                        self.renderVerticalBarId(canvasId, pairs, color, el);
                    }
                }
            });
        };

        self.renderHorizontalBar = function (refName, pairs, color) {
            var el = self.refs[refName];
            if (!el) return;
            self.renderHorizontalBarId(refName, pairs, color, el);
        };
        
        self.renderHorizontalBarId = function (id, pairs, color, elementObj) {
            var el = elementObj || document.getElementById(id);
            if (!el) return;
            var labels = pairs.map(function (p) { return p[0]; });
            var dataVals = pairs.map(function (p) { return p[1]; });

            if (self.charts[id]) {
                self.charts[id].data.labels = labels;
                self.charts[id].data.datasets[0].data = dataVals;
                self.charts[id].update();
            } else {
                self.charts[id] = new Chart(el, {
                    type: "horizontalBar",
                    data: {
                        labels: labels,
                        datasets: [{
                            data: dataVals,
                            backgroundColor: color || "#2185d0",
                            borderWidth: 0
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        legend: { display: false },
                        scales: {
                            xAxes: [{ ticks: { beginAtZero: true, precision: 0 } }],
                            yAxes: [{ gridLines: { display: false } }]
                        }
                    }
                });
            }
        };

        self.renderDoughnutId = function (id, pairs, elementObj) {
            var el = elementObj || self.refs[id];
            if (!el) return;
            var labels = pairs.map(function (p) { return p[0]; });
            var dataVals = pairs.map(function (p) { return p[1]; });

            if (self.charts[id]) {
                self.charts[id].data.labels = labels;
                self.charts[id].data.datasets[0].data = dataVals;
                self.charts[id].data.datasets[0].backgroundColor = labels.map(function (_, i) {
                    return PALETTE[(i + 5) % PALETTE.length];
                });
                self.charts[id].update();
            } else {
                self.charts[id] = new Chart(el, {
                    type: "doughnut",
                    data: {
                        labels: labels,
                        datasets: [{
                            data: dataVals,
                            backgroundColor: labels.map(function (_, i) { return PALETTE[(i + 5) % PALETTE.length]; })
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutoutPercentage: 55,
                        legend: {
                            position: "right",
                            labels: { boxWidth: 12, fontSize: 11 }
                        }
                    }
                });
            }
        };

        self.renderVerticalBarId = function (id, pairs, color, elementObj) {
            var el = elementObj || self.refs[id];
            if (!el) return;
            var labels = pairs.map(function (p) { return p[0]; });
            var dataVals = pairs.map(function (p) { return p[1]; });

            if (self.charts[id]) {
                self.charts[id].data.labels = labels;
                self.charts[id].data.datasets[0].data = dataVals;
                self.charts[id].update();
            } else {
                self.charts[id] = new Chart(el, {
                    type: "bar",
                    data: {
                        labels: labels,
                        datasets: [{
                            data: dataVals,
                            backgroundColor: color || "#a333c8",
                            borderWidth: 0
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        legend: { display: false },
                        scales: {
                            yAxes: [{ ticks: { beginAtZero: true, precision: 0 } }],
                            xAxes: [{ gridLines: { display: false } }]
                        }
                    }
                });
            }
        };

        // Export currently filtered competitions to CSV
        self.downloadCSV = function () {
            var rows = self.filteredCompetitions;
            var esc = function (v) { return '"' + String(v || '').replace(/"/g, '""') + '"'; };
            var headers = ["id", "title", "organizer", "url"].concat(self.availableCategories);
            var lines = [headers.join(",")];
            rows.forEach(function (c) {
                var rowData = [
                    c.id,
                    esc(c.title),
                    esc(c.organizer),
                    esc(c.url)
                ];
                self.availableCategories.forEach(function(cat) {
                    rowData.push(esc((c.tagsByCategory[cat] || []).join("; ")));
                });
                lines.push(rowData.join(","));
            });
            var blob = new Blob([lines.join("\n")], { type: "text/csv;charset=utf-8;" });
            var link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = "codabench_competitions_filtered.csv";
            link.click();
            URL.revokeObjectURL(link.href);
        };

    </script>

    <style type="text/stylus" scoped>
        .filter-panel
            background #fff
            border-radius 4px

        .filter-scroll-list
            max-height 170px
            overflow-y auto
            padding-right 4px

        .filter-item
            display block !important
            margin-bottom 6px !important
            font-size 12px

        .filter-count
            color #888
            font-size 11px
            margin-left 4px
            
        .kpi-stats
            display flex !important
            justify-content space-around !important
            flex-wrap wrap !important
            margin-bottom 1.2rem !important

        .chart-card
            padding 12px 14px !important

        .table-card
            padding 14px !important
            margin-top 16px !important

        .table-top-bar
            display flex
            justify-content space-between
            align-items center
            margin-bottom 12px

        .table-scroll-wrap
            max-height 480px
            overflow-y auto

        .pagination-footer
            display flex
            justify-content center
            margin-top 12px
        .dashboard-container
            margin-top 15px
            margin-bottom 40px

        .canvas-wrap
            position relative
            height 250px
            width 100%
    </style>
</dashboard>