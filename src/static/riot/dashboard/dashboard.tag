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
                <div class="ui segments filter-panel">
                    <!-- Search & Match Mode -->
                    <div class="ui segment">
                        <h4 class="ui header" style="margin-bottom: 8px;">Search</h4>
                        <div class="ui fluid small icon input">
                            <input type="text" placeholder="Title or organizer..." ref="searchInput" oninput="{ updateSearch }" value="{ state.search }">
                            <i class="search icon"></i>
                        </div>

                        <h5 class="ui header" style="margin-top: 12px; margin-bottom: 6px;">Tag Match Mode</h5>
                        <div class="ui mini fluid two buttons">
                            <button class="ui button { active: state.mode === 'or', blue: state.mode === 'or' }" onclick="{ setModeOr }">Any (OR)</button>
                            <button class="ui button { active: state.mode === 'and', blue: state.mode === 'and' }" onclick="{ setModeAnd }">All (AND)</button>
                        </div>
                    </div>

                    <!-- Admin Visibility Option -->
                    <div class="ui segment" if="{ isAdmin }">
                        <h5 class="ui header" style="margin-bottom: 6px;">Visibility</h5>
                        <div class="ui mini fluid buttons">
                            <button class="ui button { active: state.visibility === 'public', blue: state.visibility === 'public' }" onclick="{ setVisibility.bind(this, 'public') }">Public</button>
                            <button class="ui button { active: state.visibility === 'private', blue: state.visibility === 'private' }" onclick="{ setVisibility.bind(this, 'private') }">Private</button>
                            <button class="ui button { active: state.visibility === 'all', blue: state.visibility === 'all' }" onclick="{ setVisibility.bind(this, 'all') }">All</button>
                        </div>
                    </div>

                    <!-- Dynamic Categories -->
                    <div class="ui segment" each="{ cat in categoryFilters }">
                        <h5 class="ui header">{ cat.name }</h5>
                        <div class="filter-scroll-list">
                            <div class="ui checkbox filter-item" each="{ tag in cat.tags }">
                                <input type="checkbox" checked="{ tag.checked }" data-cat="{ cat.name }" data-tag="{ tag.name }" onchange="{ toggleTagHandler }">
                                <label>{ tag.name } <span class="filter-count">({ tag.count })</span></label>
                            </div>
                        </div>
                    </div>

                    <!-- Reset Filters Button -->
                    <div class="ui secondary segment">
                        <button class="ui fluid basic compact button" onclick="{ resetFilters }">
                            <i class="undo icon"></i> Reset all filters
                        </button>
                    </div>
                </div>
            </div>

            <div class="twelve wide column">
                <div class="ui four column grid kpi-stats">
                    <div class="column center aligned">
                        <div class="ui mini statistic">
                            <div class="value">{ filteredCompetitions.length }</div>
                            <div class="label">Competitions</div>
                        </div>
                    </div>
                    <div class="column center aligned">
                        <div class="ui mini statistic">
                            <div class="value">{ kpis.distinctOrganizers }</div>
                            <div class="label">Organizers</div>
                        </div>
                    </div>
                    <div class="column center aligned">
                        <div class="ui mini statistic">
                            <div class="value">{ kpis.tagsAssigned }</div>
                            <div class="label">Tags Assigned</div>
                        </div>
                    </div>
                    <div class="column center aligned">
                        <div class="ui mini statistic">
                            <div class="value">{ kpis.categoriesPresent }</div>
                            <div class="label">Categories</div>
                        </div>
                    </div>
                </div>

                <div class="ui stackable two column grid">
                    <div class="column">
                        <div class="ui segment chart-card">
                            <h4 class="ui header">Top Organizers</h4>
                            <div class="canvas-wrap">
                                <canvas ref="chOrgs"></canvas>
                            </div>
                        </div>
                    </div>
                    <div class="column" each="{ chart in chartCards }">
                        <div class="ui segment chart-card">
                            <h4 class="ui header">By { chart.catName }</h4>
                            <div class="canvas-wrap">
                                <canvas id="{ chart.id }"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="ui segment table-card">
                    <div class="table-top-bar" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                        <h3 class="ui header" style="margin: 0;">
                            Competitions ({ filteredCompetitions.length })
                        </h3>
                        <button class="ui green mini button" onclick="{ downloadCSV }">
                            <i class="download icon"></i> Download CSV
                        </button>
                    </div>

                    <div class="table-scroll-wrap" style="max-height: 480px; overflow-y: auto;">
                        <table class="ui celled compact striped selectable table">
                            <thead>
                                <tr>
                                    <th onclick="{ sortTableId }" style="cursor: pointer; width: 60px;">ID <i class="sort icon"></i></th>
                                    <th onclick="{ sortTableTitle }" style="cursor: pointer;">Title <i class="sort icon"></i></th>
                                    <th onclick="{ sortTableOrg }" style="cursor: pointer; width: 140px;">Organizer <i class="sort icon"></i></th>
                                    <th each="{ cat in availableCategories }">{ cat }</th>
                                    <th style="width: 70px; text-align: center;">Link</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr each="{ comp in pagedCompetitions }">
                                    <td>{ comp.id }</td>
                                    <td>
                                        <strong><a href="{ comp.url }">{ comp.title }</a></strong>
                                    </td>
                                    <td>{ comp.organizer }</td>
                                    <td each="{ colStr in comp.categoryColumns }">
                                        <span if="{ colStr }" style="color: #1678c2; font-weight: bold; font-size: 12px;">{ colStr }</span>
                                        <span if="{ !colStr }" style="color: #888;">—</span>
                                    </td>
                                    <td class="center aligned">
                                        <a href="{ comp.url }" class="ui mini primary icon button" target="_blank" title="View Competition">
                                            <i class="external alternate icon"></i>
                                        </a>
                                    </td>
                                </tr>
                                <tr if="{ filteredCompetitions.length === 0 }">
                                    <td colspan="10" class="center aligned">
                                        <em>No competitions match the selected filters.</em>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="pagination-footer" if="{ totalPages > 1 }" style="display: flex; justify-content: center; margin-top: 12px;">
                        <div class="ui secondary compact menu">
                            <a class="item { disabled: currentPage === 1 }" onclick="{ changePagePrev }">
                                <i class="chevron left icon"></i> Prev
                            </a>
                            <div class="item">Page { currentPage } of { totalPages }</div>
                            <a class="item { disabled: currentPage === totalPages }" onclick="{ changePageNext }">
                                Next <i class="chevron right icon"></i>
                            </a>
                        </div>
                    </div>
                </div>
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
            tagsAssigned: 0,
            categoriesPresent: 0
        };

        // Filter and sort state
        self.state = {
            search: "",
            mode: "or",
            visibility: "public",
            selectedTags: {},
            sortKey: "id",
            sortDir: 1
        };

        self.charts = {};

        var PALETTE = ["#2185d0", "#00b5ad", "#21ba45", "#fbbd08", "#f2711c", "#db2828", "#a333c8", "#e03997", "#767676"];

        self.on('mount', function () {
            self.fetchData();
        });

        // Recursively fetch competitions using the main endpoint with visibility
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
                $.ajax({
                    url: url,
                    type: "GET",
                    success: function (resp) {
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
                        }
                    },
                    error: function () {
                        if (allResults.length > 0) {
                            self.allCompetitions = self.classifyCompetitions(allResults);
                        } else {
                            self.allCompetitions = [];
                        }
                        self.dataSource = "api";
                        self.onDataLoaded();
                    }
                });
            }

            fetchPage(apiUrl);
        };

        self.onDataLoaded = function () {
            self.loading = false;
            self.applyFilters();
            self.update();
            setTimeout(function () {
                self.initOrUpdateCharts();
            }, 50);
        };

        // Parse raw API results, extracting categories and globally unique tags
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
            self.currentPage = 1;
            self.applyFilters();
            self.update();
            setTimeout(self.initOrUpdateCharts, 50);
        };

        self.updateSearch = function (e) {
            self.state.search = e.target.value.toLowerCase();
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

        // Apply text search and tag filters, then rebuild category counts and pagination
        self.applyFilters = function () {
            var s = self.state.search;
            self.filteredCompetitions = self.allCompetitions.filter(function (c) {
                if (self.isAdmin) {
                    if (self.state.visibility === 'public' && !c.published) return false;
                    if (self.state.visibility === 'private' && c.published) return false;
                }
                if (s && c.title.toLowerCase().indexOf(s) === -1 && c.organizer.toLowerCase().indexOf(s) === -1) {
                    return false;
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
            
            self.filteredCompetitions.forEach(function (c) {
                orgs[c.organizer] = true;
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

        // Render charts dynamically using a modulo rule for chart types (Bar/Doughnut)
        self.initOrUpdateCharts = function () {
            var rows = self.filteredCompetitions;
            
            var oPairs = countOrgs(rows, 10);
            self.renderHorizontalBar("chOrgs", oPairs, "#21ba45");

            self.availableCategories.forEach(function(cat, idx) {
                var counts = self.categoryTagsCounts[cat] || {};
                var pairs = Object.keys(counts).map(function(k) { return [k, counts[k]]; });
                pairs.sort(function(a, b) { return b[1] - a[1]; });
                pairs = pairs.slice(0, 15);
                
                var canvasId = "chart_cat_" + idx;
                var el = document.getElementById(canvasId);
                var color = PALETTE[idx % PALETTE.length];
                
                if (el) {
                    if (idx % 3 === 0) {
                        self.renderHorizontalBarId(canvasId, pairs, color);
                    } else if (idx % 3 === 1) {
                        self.renderDoughnutId(canvasId, pairs);
                    } else {
                        self.renderVerticalBarId(canvasId, pairs, color);
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

        self.renderDoughnutId = function (id, pairs) {
            var el = document.getElementById(id);
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

        self.renderVerticalBarId = function (id, pairs, color) {
            var el = document.getElementById(id);
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

    <style type="text/stylus">
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