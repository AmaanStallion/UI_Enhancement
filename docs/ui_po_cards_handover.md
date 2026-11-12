# PO card and Verify form UI handover

Prepared: 2026-11-12 (Asia/Calcutta).

Status: the user authorized committing and pushing this eight-file handover on 2026-11-12. The delivery identifier is the commit containing this guide; the exact hash and verified push outcome are reported in chat.

## Comparison baseline

- Repository: https://github.com/AmaanStallion/UI_Enhancement (public by prior user instruction).
- Current branch: `codex/ui-po-verified-handover`.
- Previous delivered commit: `e3fed6273344812b6433c72e62321dbb79d281a9`.
- Confirm that the integration developer imported this exact baseline commit. Compare only `e3fed6273344812b6433c72e62321dbb79d281a9..NEW_HASH` for this import; do not re-import prior handovers. Use the exact new delivery hash reported in chat, rather than relying on the branch name alone.

## Final visible behaviour

- All three PO lists (Verified, Assigned, Issued): only one card is expanded at a time. Expanding another closes the previous card; only the arrow controls expansion. Body navigation and action permissions remain existing behaviour.
- Collapsed widths match expanded widths: 12-pixel mobile and 40-pixel desktop horizontal margins. Desktop label/value spacing matches expanded rows, including minus separators. Mobile label columns use the expanded layout's bounded 35% rule. Text origins, arrow centers and action horizontal anchors match across expansion; a top-anchored 220ms AnimatedSize transition gives vertical expansion, disabled for reduced-motion preferences.
- Collapsed typography follows expanded styles (HelveticaNeue, 14 desktop / 13 compact; bold PO number and status, regular other values). All card action text is uppercase. Yellow/blue/green badge fills are stronger; Verify PO summary status colors match. Expanded Issued PO status uses the same 5-pixel rounded rectangle as other badges.
- Expanded layout's redundant noninteractive navigation chevron is removed so its reserved space no longer pushes action buttons left. Body tap navigation remains. Expanded arrow stays on its own row above details. Button order/grouping and action callbacks are retained except the explicitly requested collapsed Issued replacement below.
- Issued collapsed actions: DEL. QTY., CHALLAN, E-SIGN. E-SIGN replaces View Doc, uses the existing signature dialog and is disabled without `authorizeFlag == '1'`. Issued signatures remain read-only. Documents remain available after expansion as DOC.; expanded GRN and CHALLAN use shortened names, preserving existing GRN visibility/permissions.
- All Issued action containers use equal dimensions: 56×30 logical pixels on mobile, 64×30 on desktop; DOC. font size matches DEL. QTY./CHALLAN. Collapsed action gaps remain 6 pixels.
- Final Issued collapsed fixed height is 272 compact / 220 desktop, with 12-pixel top/bottom padding. This supersedes earlier smaller trial sizes that clipped Order Pending after typography/separator changes. Cards are equal within each layout. Full sample Delivery Status badge is visible without scrolling; automatic internal scrollbar is hidden. Longer content retains internal scrolling. Verified/Assigned remain content-sized.
- Verify PO form: display labels Grade type and Grade name replace Requirement Type and Description / Sub type. Adjacent info icons support tap and hover, also when interacting with the label. Exact tips: `Also know as Requirement/Product type` and `Grade name: Also known as Description/Sub type`. Input positions, widths, editing, dropdown handlers and internal field names/keys are unchanged.

## Authorized manifest (8 files)

| Path | Change |
| --- | --- |
| `lib/ui/views/accountmanagement/porequested.dart` | Modified: shared PO card UI/expansion |
| `lib/ui/views/accountmanagement/podetails.dart` | Modified: grade labels/tooltips and summary status color |
| `test/po_assigned_cards_test.dart` | Modified: uppercase action expectations |
| `test/po_issued_cards_test.dart` | Modified: collapsed E-SIGN, dimensions, expanded actions and badge visibility |
| `test/po_verified_handover_test.dart` | Modified: uppercase actions, exact tooltip tap/hover checks |
| `test/po_card_expansion_test.dart` | Added: exclusive expansion and stable alignment on all states/viewports |
| `docs/ui_handover.md` | Modified: cumulative working record |
| `docs/ui_po_cards_handover.md` | Added: this final comparison/import guide |

No renames/deletions. No added assets, fonts, dependencies, lockfile or platform changes. Existing shared helpers, preview support and dependencies are supplied by the previous handovers.

Exclude all unlisted local changes, including Accounts dashboard, WO/payment/Status of Supplies screens, `poassignedpreviewhtml.dart`, `quote_pdf.dart`, the broad `test/account_management_preview_test.dart`, `AGENTS.md`, `flutter_01.png` and generated output. The broad test contains older unrelated edits alongside current PO expectation updates; use the focused tests as this batch's boundary.

## Widget/API/integration boundary

- Public screen constructors and filenames are stable. Changes use existing widget/state architecture; new helpers and keys are private presentation details.
- No new data fields or backend actions are required. Continue supplying existing unique order/project/tower IDs, PO/date/status/grade/delivery/document data, signature and GRN flags, and existing form models/controllers.
- Actions remain current navigation, document/delivery/signature handlers, form editing and current saves/assignment/vendor-quote operations. Preserve the integration project's backend/Postman definitions when merging these shared files.
- Both UI files contain API code, but this batch changes presentation and local expansion state only. No endpoint/authentication/token/payload or server business-rule changes are intended. Demonstration configuration and fixture files are unchanged from the comparison baseline; no new live integration is claimed.
- Existing debug preview mode and local unit examples remain demonstration-only. Do not treat passing offline tests as confirmation of live permissions, persistence or API behaviour.

## Checks and limitations

- Isolated verification passed all 15 tests using exactly the previous delivered commit plus the eight manifest files, with existing resolved dependency metadata copied/remapped for `--no-pub`. No other dirty source files were copied.
- Checks exercised mobile 390 / desktop 1920, tooltip tap and desktop hover, card action/navigation/permission behaviour, exclusive expansion and horizontal anchors, full sample delivery badge containment, and the existing pointer-feedback test. Tracked candidate whitespace checks passed.
- Both UI files retain identical code preceding their build methods and unchanged AppUrl reference sequences versus the comparison baseline. Narrow selected-file private-key/GitHub/AWS credential-pattern scan found no matches; this is not a complete secret audit. Source/test hashes were checked against the isolated tested snapshot.
- No live backend requests, native upload, fresh dependency resolution, release build or screenshot acceptance review. Existing resolved tests use an SDK newer than the manifest's Dart `<3.0.0` constraint; `--no-pub` checks do not establish clean dependency resolution.
- Card equal-height/visibility checks cover supplied fixtures at the tested widths; arbitrary long production text and nondefault accessibility scaling remain unverified. Hidden scrollbars do not disable access to longer Issued summaries by scrolling.

## Import this delivery

Only these eight files are authorized for publication on `codex/ui-po-verified-handover`, preserving prior history. Use the repository URL, exact new hash and baseline-to-new-hash comparison link reported in chat. The integration developer should import only that delta, merge UI onto current backend files and record the new exact hash as the next handover baseline.
