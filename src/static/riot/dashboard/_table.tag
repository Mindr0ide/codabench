<dashboard-table>
    <div class="ui segment table-card">
                    <div class="table-top-bar" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                        <h3 class="ui header" style="margin: 0;">
                            Competitions ({ opts.p.filteredCompetitions.length })
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
                                    <th each="{ cat in opts.p.availableCategories }">{ cat }</th>
                                    <th style="width: 70px; text-align: center;">Link</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr each="{ comp in opts.p.pagedCompetitions }">
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
                                <tr if="{ opts.p.filteredCompetitions.length === 0 }">
                                    <td colspan="10" class="center aligned">
                                        <em>No competitions match the selected filters.</em>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="pagination-footer" if="{ opts.p.totalPages > 1 }" style="display: flex; justify-content: center; margin-top: 12px;">
                        <div class="ui secondary compact menu">
                            <a class="item { disabled: opts.p.currentPage === 1 }" onclick="{ changePagePrev }">
                                <i class="chevron left icon"></i> Prev
                            </a>
                            <div class="item">Page { opts.p.currentPage } of { opts.p.totalPages }</div>
                            <a class="item { disabled: opts.p.currentPage === opts.p.totalPages }" onclick="{ changePageNext }">
                                Next <i class="chevron right icon"></i>
                            </a>
                        </div>
                    </div>
                </div>
    <script>
        var self = this;
        self.downloadCSV = function(e) { opts.p.downloadCSV(e); };
        self.sortTableId = function(e) { opts.p.sortTableId(e); };
        self.sortTableTitle = function(e) { opts.p.sortTableTitle(e); };
        self.sortTableOrg = function(e) { opts.p.sortTableOrg(e); };
        self.changePagePrev = function(e) { opts.p.changePagePrev(e); };
        self.changePageNext = function(e) { opts.p.changePageNext(e); };
    </script>
</dashboard-table>
