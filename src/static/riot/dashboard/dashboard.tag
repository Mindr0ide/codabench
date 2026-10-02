<dashboard>
    <div class="sixteen wide column dashboard-container">
        <!-- Header Banner -->
        <div class="ui stackable grid">
            <div class="eleven wide column">
                <h2 class="ui header">
                    <i class="chart bar outline icon"></i>
                    <div class="content">
                        Competitions Dashboard
                        <div class="sub header">Explore and analyze benchmarks across research fields, application sectors, conferences, and countries</div>
                    </div>
                </h2>
            </div>
            <div class="five wide right aligned column">
                <div class="ui mini label">
                    <i class="database icon"></i> Live API Data ({ allCompetitions.length })
                </div>
            </div>
        </div>

        <div class="ui divider"></div>

        <!-- Dimmer Loading State -->
        <div class="ui active inverted dimmer" if="{ loading }">
            <div class="ui text loader">Loading competitions and analytics...</div>
        </div>

        <!-- Main Layout Grid -->
        <div class="ui stackable grid" if="{ !loading }">
            <!-- Left Sidebar / Filters (4 Wide) -->
            <div class="four wide column">
                <div class="ui segments filter-panel">
                    <!-- Search & Match Mode -->
                    <div class="ui segment">
                        <h4 class="ui header" style="margin-bottom: 8px;">Search</h4>
                        <div class="ui fluid small icon input">
                            <input type="text" placeholder="Title or organizer..." ref="searchInput" oninput="{ onSearchInput }" value="{ state.search }">
                            <i class="search icon"></i>
                        </div>

                        <h5 class="ui header" style="margin-top: 12px; margin-bottom: 6px;">Tag Match Mode</h5>
                        <div class="ui mini fluid two buttons">
                            <button class="ui button { active: state.mode === 'or', blue: state.mode === 'or' }" onclick="{ setMatchMode.bind(this, 'or') }">Any (OR)</button>
                            <button class="ui button { active: state.mode === 'and', blue: state.mode === 'and' }" onclick="{ setMatchMode.bind(this, 'and') }">All (AND)</button>
                        </div>
                    </div>

                    <!-- Research Fields -->
                    <div class="ui segment">
                        <h5 class="ui header">Research Field</h5>
                        <div class="filter-scroll-list">
                            <div class="ui checkbox filter-item" each="{ name in taxonomy.domains }">
                                <input type="checkbox" checked="{ state.domains.has(name) }" onchange="{ toggleFilter.bind(this, 'domains', name) }">
                                <label>{ name } <span class="filter-count">({ getTagCount('domains', name) })</span></label>
                            </div>
                        </div>
                    </div>

                    <!-- Application Sectors -->
                    <div class="ui segment">
                        <h5 class="ui header">Application Sector</h5>
                        <div class="filter-scroll-list">
                            <div class="ui checkbox filter-item" each="{ name in taxonomy.sectors }">
                                <input type="checkbox" checked="{ state.sectors.has(name) }" onchange="{ toggleFilter.bind(this, 'sectors', name) }">
                                <label>{ name } <span class="filter-count">({ getTagCount('sectors', name) })</span></label>
                            </div>
                        </div>
                    </div>

                    <!-- Conferences -->
                    <div class="ui segment">
                        <h5 class="ui header">Conference / Venue</h5>
                        <div class="filter-scroll-list">
                            <div class="ui checkbox filter-item" each="{ name in taxonomy.conferences }">
                                <input type="checkbox" checked="{ state.conferences.has(name) }" onchange="{ toggleFilter.bind(this, 'conferences', name) }">
                                <label>{ name } <span class="filter-count">({ getTagCount('conferences', name) })</span></label>
                            </div>
                        </div>
                    </div>

                    <!-- Countries -->
                    <div class="ui segment">
                        <h5 class="ui header">Country <small style="font-weight:normal; color:#888;">(inferred)</small></h5>
                        <div class="filter-scroll-list">
                            <div class="ui checkbox filter-item" each="{ name in taxonomy.countries }">
                                <input type="checkbox" checked="{ state.countries.has(name) }" onchange="{ toggleFilter.bind(this, 'countries', name) }">
                                <label>{ name } <span class="filter-count">({ getTagCount('countries', name) })</span></label>
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

            <!-- Right Main Area (12 Wide) -->
            <div class="twelve wide column">
                <!-- KPI Statistics -->
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
                            <div class="value">{ kpis.fieldTagged }</div>
                            <div class="label">Field Tagged</div>
                        </div>
                    </div>
                    <div class="column center aligned">
                        <div class="ui mini statistic">
                            <div class="value">{ kpis.conferenceLinked }</div>
                            <div class="label">In Conferences</div>
                        </div>
                    </div>
                </div>

                <!-- 2x2 Charts Grid -->
                <div class="ui stackable two column grid">
                    <div class="column">
                        <div class="ui segment chart-card">
                            <h4 class="ui header">By Research Field</h4>
                            <div class="canvas-wrap">
                                <canvas ref="chDomains"></canvas>
                            </div>
                        </div>
                    </div>
                    <div class="column">
                        <div class="ui segment chart-card">
                            <h4 class="ui header">By Application Sector</h4>
                            <div class="canvas-wrap">
                                <canvas ref="chSectors"></canvas>
                            </div>
                        </div>
                    </div>
                    <div class="column">
                        <div class="ui segment chart-card">
                            <h4 class="ui header">Top Organizers</h4>
                            <div class="canvas-wrap">
                                <canvas ref="chOrgs"></canvas>
                            </div>
                        </div>
                    </div>
                    <div class="column">
                        <div class="ui segment chart-card">
                            <h4 class="ui header">By Conference / Venue</h4>
                            <div class="canvas-wrap">
                                <canvas ref="chConfs"></canvas>
                            </div>
                        </div>
                    </div>
                    <div class="sixteen wide column">
                        <div class="ui segment chart-card">
                            <h4 class="ui header">By Country <small style="font-weight:normal; color:#888;">(inferred from text)</small></h4>
                            <div class="canvas-wrap-wide">
                                <canvas ref="chCountries"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Competitions Table Section -->
                <div class="ui segment table-card">
                    <div class="table-top-bar">
                        <h3 class="ui header" style="margin: 0;">
                            Competitions ({ filteredCompetitions.length })
                        </h3>
                        <button class="ui green mini button" onclick="{ downloadCSV }">
                            <i class="download icon"></i> Download filtered CSV
                        </button>
                    </div>

                    <div class="table-scroll-wrap">
                        <table class="ui celled compact striped selectable table">
                            <thead>
                                <tr>
                                    <th onclick="{ sortTable.bind(this, 'id') }" style="cursor: pointer; width: 60px;">ID <i class="sort icon"></i></th>
                                    <th onclick="{ sortTable.bind(this, 'title') }" style="cursor: pointer;">Title <i class="sort icon"></i></th>
                                    <th onclick="{ sortTable.bind(this, 'organizer') }" style="cursor: pointer; width: 140px;">Organizer <i class="sort icon"></i></th>
                                    <th>Field</th>
                                    <th>Sector</th>
                                    <th>Conference</th>
                                    <th>Country</th>
                                    <th style="width: 70px; text-align: center;">Link</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr each="{ comp in pagedCompetitions }">
                                    <td>{ comp.id }</td>
                                    <td>
                                        <strong><a href="{ comp.url || (URLS.COMPETITION_DETAIL ? URLS.COMPETITION_DETAIL(comp.id) : '/competitions/' + comp.id + '/') }">{ comp.title }</a></strong>
                                    </td>
                                    <td>{ comp.organizer }</td>
                                    <td>
                                        <span each="{ t in comp.domains }" class="ui mini blue basic label tag-label">{ t }</span>
                                        <span if="{ !comp.domains || comp.domains.length === 0 }" class="text-muted">—</span>
                                    </td>
                                    <td>
                                        <span each="{ t in comp.sectors }" class="ui mini teal basic label tag-label">{ t }</span>
                                        <span if="{ !comp.sectors || comp.sectors.length === 0 }" class="text-muted">—</span>
                                    </td>
                                    <td>
                                        <span each="{ t in comp.conferences }" class="ui mini orange basic label tag-label">{ t }</span>
                                        <span if="{ !comp.conferences || comp.conferences.length === 0 }" class="text-muted">—</span>
                                    </td>
                                    <td>
                                        <span each="{ t in comp.countries }" class="ui mini purple basic label tag-label">{ t }</span>
                                        <span if="{ !comp.countries || comp.countries.length === 0 }" class="text-muted">—</span>
                                    </td>
                                    <td class="center aligned">
                                        <a href="{ comp.url || (URLS.COMPETITION_DETAIL ? URLS.COMPETITION_DETAIL(comp.id) : '/competitions/' + comp.id + '/') }" class="ui mini primary icon button" target="_blank" title="View Competition">
                                            <i class="external alternate icon"></i>
                                        </a>
                                    </td>
                                </tr>
                                <tr if="{ filteredCompetitions.length === 0 }">
                                    <td colspan="8" class="center aligned">
                                        <em>No competitions match the selected filters. Try clearing some filters.</em>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div class="pagination-footer" if="{ totalPages > 1 }">
                        <div class="ui secondary compact menu">
                            <a class="item { disabled: currentPage === 1 }" onclick="{ changePage.bind(this, -1) }">
                                <i class="chevron left icon"></i> Prev
                            </a>
                            <div class="item">Page { currentPage } of { totalPages }</div>
                            <a class="item { disabled: currentPage === totalPages }" onclick="{ changePage.bind(this, 1) }">
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

        self.loading = true;
        self.dataSource = "mock";
        self.allCompetitions = [];
        self.filteredCompetitions = [];
        self.pagedCompetitions = [];
        self.pageSize = 15;
        self.currentPage = 1;
        self.totalPages = 1;

        self.kpis = {
            distinctOrganizers: 0,
            fieldTagged: 0,
            conferenceLinked: 0
        };

        self.state = {
            search: "",
            mode: "or",
            domains: new Set(),
            sectors: new Set(),
            conferences: new Set(),
            countries: new Set(),
            sortKey: "id",
            sortDir: 1
        };

        self.charts = {};

        var PALETTE = ["#2185d0", "#00b5ad", "#21ba45", "#fbbd08", "#f2711c", "#db2828", "#a333c8", "#e03997", "#767676"];

        self.taxonomy = {
            domains: [
                "NLP / Text", "Computer Vision", "Speech & Audio",
                "Time Series / Forecasting", "Graph / Networks", "Reinforcement Learning",
                "Recommender Systems", "Generative / LLM", "Tabular / Classical ML"
            ],
            sectors: [
                "Healthcare & Biomedicine", "Finance", "Climate & Energy",
                "E-commerce & Retail", "Security & Privacy", "Robotics & Autonomous",
                "Agriculture & Food", "Transportation & Mobility"
            ],
            conferences: [
                "NeurIPS", "CVPR", "ICCV", "ECCV", "ICML", "ICLR", "ACL", "MICCAI", "WSDM", "NAACL", "ECML / PKDD"
            ],
            countries: [
                "France", "China", "Germany", "India", "USA", "UK", "Japan", "Canada"
            ]
        };

        
        self.on('mount', function () {
            self.fetchData();
        });

        self.on('unmount', function () {
            Object.keys(self.charts).forEach(function (k) {
                if (self.charts[k]) {
                    self.charts[k].destroy();
                }
            });
            self.charts = {};
        });

        self.fetchData = function () {
            self.loading = true;
            self.update();

            if (typeof CODALAB !== "undefined" && CODALAB.api && CODALAB.api.get_competitions) {
                CODALAB.api.get_competitions({ page_size: 100 })
                    .done(function (resp) {
                        var results = (resp && resp.results) ? resp.results : [];
                        self.allCompetitions = self.classifyCompetitions(results);
                        self.dataSource = "api";
                        self.onDataLoaded();
                    })
                    .fail(function () {
                        self.allCompetitions = [];
                        self.dataSource = "api";
                        self.onDataLoaded();
                    });
            } else {
                self.allCompetitions = [];
                self.dataSource = "api";
                self.onDataLoaded();
            }
        };

        self.onDataLoaded = function () {
            self.loading = false;
            self.applyFilters();
            self.update();
            setTimeout(function () {
                self.initOrUpdateCharts();
            }, 50);
        };

        self.classifyCompetitions = function (list) {
            return list.map(function (item) {
                var comp = {
                    id: item.id,
                    title: item.title,
                    organizer: item.created_by || item.owner_display_name || "organizer",
                    url: (typeof URLS !== "undefined" && URLS.COMPETITION_DETAIL) ? URLS.COMPETITION_DETAIL(item.id) : ("/competitions/" + item.id + "/"),
                    domains: [],
                    sectors: [],
                    conferences: [],
                    countries: []
                };

                // Use real tags from backend
                if (item.tags && Array.isArray(item.tags)) {
                    item.tags.forEach(function(tag) {
                        var catName = (tag.category || "").toLowerCase();
                        if (catName.indexOf('ml') !== -1 || catName.indexOf('machine') !== -1) {
                            comp.domains.push(tag.name);
                        } else if (catName.indexOf('sector') !== -1) {
                            comp.sectors.push(tag.name);
                        } else if (catName.indexOf('conference') !== -1) {
                            comp.conferences.push(tag.name);
                        } else if (catName.indexOf('countr') !== -1 || catName.indexOf('pays') !== -1) {
                            comp.countries.push(tag.name);
                        } else {
                            comp.domains.push(tag.name); // Default fallback
                        }
                    });
                }
                return comp;
            });
        };

        self.getTagCount = function (tagType, tagName) {
            var count = 0;
            self.allCompetitions.forEach(function (c) {
                if (c[tagType] && c[tagType].indexOf(tagName) !== -1) count++;
            });
            return count;
        };

        function tagMatch(itemTags, selectedSet) {
            if (selectedSet.size === 0) return true;
            if (self.state.mode === "and") {
                for (var it of selectedSet) {
                    if (itemTags.indexOf(it) === -1) return false;
                }
                return true;
            }
            for (var it of selectedSet) {
                if (itemTags.indexOf(it) !== -1) return true;
            }
            return false;
        }

        self.applyFilters = function () {
            var q = (self.state.search || "").toLowerCase().trim();
            self.filteredCompetitions = self.allCompetitions.filter(function (c) {
                var searchMatches = (q === "") || ((c.title + " " + c.organizer).toLowerCase().indexOf(q) !== -1);
                return searchMatches &&
                    tagMatch(c.domains, self.state.domains) &&
                    tagMatch(c.sectors, self.state.sectors) &&
                    tagMatch(c.conferences, self.state.conferences) &&
                    tagMatch(c.countries, self.state.countries);
            });

            // Update KPIs
            var orgs = new Set(self.filteredCompetitions.map(function (c) { return c.organizer; }));
            self.kpis.distinctOrganizers = orgs.size;
            self.kpis.fieldTagged = self.filteredCompetitions.filter(function (c) { return c.domains && c.domains.length > 0; }).length;
            self.kpis.conferenceLinked = self.filteredCompetitions.filter(function (c) { return c.conferences && c.conferences.length > 0; }).length;

            // Sort and paginate
            self.sortFilteredCompetitions();
            self.currentPage = 1;
            self.paginateTable();
        };

        self.sortFilteredCompetitions = function () {
            var k = self.state.sortKey;
            var d = self.state.sortDir;
            self.filteredCompetitions.sort(function (a, b) {
                var x = a[k], y = b[k];
                if (typeof x === "string") return x.localeCompare(y) * d;
                return ((x || 0) - (y || 0)) * d;
            });
        };

        self.paginateTable = function () {
            self.totalPages = Math.max(1, Math.ceil(self.filteredCompetitions.length / self.pageSize));
            if (self.currentPage > self.totalPages) self.currentPage = self.totalPages;
            var start = (self.currentPage - 1) * self.pageSize;
            self.pagedCompetitions = self.filteredCompetitions.slice(start, start + self.pageSize);
        };

        self.changePage = function (delta) {
            var target = self.currentPage + delta;
            if (target >= 1 && target <= self.totalPages) {
                self.currentPage = target;
                self.paginateTable();
                self.update();
            }
        };

        self.sortTable = function (key) {
            if (self.state.sortKey === key) {
                self.state.sortDir = -self.state.sortDir;
            } else {
                self.state.sortKey = key;
                self.state.sortDir = 1;
            }
            self.sortFilteredCompetitions();
            self.paginateTable();
            self.update();
        };

        self.onSearchInput = function (e) {
            self.state.search = e.target.value;
            self.applyFilters();
            self.update();
            self.initOrUpdateCharts();
        };

        self.setMatchMode = function (mode) {
            self.state.mode = mode;
            self.applyFilters();
            self.update();
            self.initOrUpdateCharts();
        };

        self.toggleFilter = function (type, name, e) {
            if (e.target.checked) {
                self.state[type].add(name);
            } else {
                self.state[type].delete(name);
            }
            self.applyFilters();
            self.update();
            self.initOrUpdateCharts();
        };

        self.resetFilters = function () {
            self.state.search = "";
            self.state.mode = "or";
            self.state.domains.clear();
            self.state.sectors.clear();
            self.state.conferences.clear();
            self.state.countries.clear();
            if (self.refs.searchInput) self.refs.searchInput.value = "";
            self.applyFilters();
            self.update();
            self.initOrUpdateCharts();
        };

        // Chart helpers compatible with Chart.js 2.7.3
        function countBy(rows, key) {
            var map = {};
            rows.forEach(function (r) {
                (r[key] || []).forEach(function (t) {
                    map[t] = (map[t] || 0) + 1;
                });
            });
            var entries = Object.keys(map).map(function (k) { return [k, map[k]]; });
            entries.sort(function (a, b) { return b[1] - a[1]; });
            return entries;
        }

        function countOrgs(rows, limit) {
            var map = {};
            rows.forEach(function (r) {
                map[r.organizer] = (map[r.organizer] || 0) + 1;
            });
            var entries = Object.keys(map).map(function (k) { return [k, map[k]]; });
            entries.sort(function (a, b) { return b[1] - a[1]; });
            return entries.slice(0, limit);
        }

        self.initOrUpdateCharts = function () {
            var rows = self.filteredCompetitions;
            var dPairs = countBy(rows, "domains");
            var sPairs = countBy(rows, "sectors");
            var oPairs = countOrgs(rows, 10);
            var cPairs = countBy(rows, "conferences");
            var kPairs = countBy(rows, "countries");

            self.renderHorizontalBar("chDomains", dPairs, "#2185d0");
            self.renderHorizontalBar("chSectors", sPairs, "#00b5ad");
            self.renderHorizontalBar("chOrgs", oPairs, "#21ba45");
            self.renderDoughnut("chConfs", cPairs);
            self.renderVerticalBar("chCountries", kPairs, "#a333c8");
        };

        self.renderHorizontalBar = function (refName, pairs, color) {
            var el = self.refs[refName];
            if (!el) return;
            var labels = pairs.map(function (p) { return p[0]; });
            var dataVals = pairs.map(function (p) { return p[1]; });

            if (self.charts[refName]) {
                self.charts[refName].data.labels = labels;
                self.charts[refName].data.datasets[0].data = dataVals;
                self.charts[refName].update();
            } else {
                self.charts[refName] = new Chart(el, {
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

        self.renderDoughnut = function (refName, pairs) {
            var el = self.refs[refName];
            if (!el) return;
            var labels = pairs.map(function (p) { return p[0]; });
            var dataVals = pairs.map(function (p) { return p[1]; });

            if (self.charts[refName]) {
                self.charts[refName].data.labels = labels;
                self.charts[refName].data.datasets[0].data = dataVals;
                self.charts[refName].data.datasets[0].backgroundColor = labels.map(function (_, i) {
                    return PALETTE[i % PALETTE.length];
                });
                self.charts[refName].update();
            } else {
                self.charts[refName] = new Chart(el, {
                    type: "doughnut",
                    data: {
                        labels: labels,
                        datasets: [{
                            data: dataVals,
                            backgroundColor: labels.map(function (_, i) { return PALETTE[i % PALETTE.length]; })
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

        self.renderVerticalBar = function (refName, pairs, color) {
            var el = self.refs[refName];
            if (!el) return;
            var labels = pairs.map(function (p) { return p[0]; });
            var dataVals = pairs.map(function (p) { return p[1]; });

            if (self.charts[refName]) {
                self.charts[refName].data.labels = labels;
                self.charts[refName].data.datasets[0].data = dataVals;
                self.charts[refName].update();
            } else {
                self.charts[refName] = new Chart(el, {
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

        self.downloadCSV = function () {
            var rows = self.filteredCompetitions;
            var esc = function (v) { return '"' + String(v || '').replace(/"/g, '""') + '"'; };
            var headers = ["id", "title", "organizer", "url", "domains", "sectors", "conferences", "countries"];
            var lines = [headers.join(",")];
            rows.forEach(function (c) {
                lines.push([
                    c.id,
                    esc(c.title),
                    esc(c.organizer),
                    esc(c.url),
                    esc((c.domains || []).join("; ")),
                    esc((c.sectors || []).join("; ")),
                    esc((c.conferences || []).join("; ")),
                    esc((c.countries || []).join("; "))
                ].join(","));
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
        .dashboard-container
            margin-top 15px
            margin-bottom 40px

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

        .canvas-wrap
            position relative
            height 250px
            width 100%

        .canvas-wrap-wide
            position relative
            height 200px
            width 100%

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

        .tag-label
            margin 1px 2px !important

        .pagination-footer
            display flex
            justify-content center
            margin-top 12px

        .text-muted
            color #888
    </style>
</dashboard>