# Follow-up UI handover: PO Assigned / Issued and related refinements

Prepared: 2026-11-12 (Asia/Calcutta).

Status: the user authorized committing and pushing this 12-file handover on 2026-11-12. The delivery identifier is the commit containing this guide; its exact hash and verified push result are reported in chat.

## Compare against the previous delivery

- Repository: https://github.com/AmaanStallion/UI_Enhancement (public, as explicitly authorized previously).
- Current branch: `codex/ui-po-verified-handover`.
- Previous delivered commit and required comparison baseline: `50bc6c792741e1464d9744afce792c0013ff8005`.
- Confirm that the integration developer imported that exact hash. If a different hash was imported, compare against that hash before applying this batch.
- This batch contains subsequent changes only. Do not re-import the first handover or unrelated dirty working-tree files. Use the exact delivery hash reported in chat after publication; the branch name alone is not a stable import identifier.

## Final visible behaviour

- Account Management main: regular-weight status counts; tower name and arrow close and centered in a shorter row, with full-width black borders above/below the row.
- Verified and Assigned/Issued date filters: compact controls with taller aligned desktop date fields. Assigned/Issued use the same toolbar styling and no divider below search.
- Assigned: independent arrow-only collapse/expand, five summary fields, View Doc and E-Sign visible while collapsed. E-Sign remains disabled for unauthorized rows; body navigation retains the existing Assigned handler.
- Issued: same five summary fields and raised/pastel styling. Collapsed cards share a fixed 190-logical-pixel height, 5-pixel top/bottom padding and 6-pixel gaps between Del. Qty., Challan and View Doc. These are the only three collapsed actions. Conditional View GRN and authorized E-Sign remain in the expanded layout. Long summary content can scroll within the left column. The final summary row uses the available height to reduce space below Delivery Status.
- Expanded Assigned/Issued details start below a separate arrow row, use less top padding, and omit the divider below Grades. Existing expanded action positions/order are retained.
- Assigned/Issued filter: responsive bounded dialog, centered white title on black, category selection, white search, grey choices, right-aligned black selection icons, side-by-side capsule Reset/Apply Filter buttons and active-filter icon tint.
- Issued delivery/document dialogs: grey delivery table rows without row rules; viewport-based document dialog height. Existing signature/document actions are retained.
- E-Sign pad: thin continuous rounded outline painted above clipped content, with responsive existing dialog styling and capsule actions. Signature handling and Issued read-only behaviour remain unchanged.
- Verify PO: Other Remarks precedes Upload; both use the input grid's insets/columns. Remarks remains two lines. Input cards have a lighter border/subtle shadow. Labels use one line except Description/Sub type. View PO is shorter. Requirement Type is left-aligned and vertically centered using dense decoration; Requirement Type and unit selectors use down chevrons. Input widths/positions and footer layout are retained.
- View GRN: responsive cards, no divider below content, vertically centered right arrow, and local search across loaded GRN number, booking type, challan, grade and date. Clearing restores the loaded rows; no-result state is shown. Document opening uses the filtered record.

## Authorized file manifest (12 files)

Paths are relative to the repository root. No renames or deletions.

| File | Change |
| --- | --- |
| `lib/ui/views/accountmanagement/accountmanagement.dart` | Modified: main-screen refinements |
| `lib/ui/views/accountmanagement/account_management_fixtures.dart` | Modified: Assigned/Issued-only sample filter options |
| `lib/ui/views/accountmanagement/porequested.dart` | Modified: shared PO list presentation, dialogs, Assigned/Issued behaviour |
| `lib/ui/views/accountmanagement/podetails.dart` | Modified: Verify PO form refinements |
| `lib/ui/views/accountmanagement/signature_dialog.dart` | Modified: related signature popup presentation |
| `lib/ui/views/accountmanagement/grnlistingview.dart` | Modified: related GRN presentation and local search |
| `lib/ui/views/accountmanagement/chalan_Screen.dart` | Modified: related responsive Challan presentation/loading |
| `lib/ui/views/accountmanagement/po_assigned_filter_dialog.dart` | Added: reusable Assigned/Issued filter presentation |
| `test/po_assigned_cards_test.dart` | Added: network-blocked mobile/desktop Assigned checks |
| `test/po_issued_cards_test.dart` | Added: network-blocked mobile/desktop Issued/GRN checks |
| `docs/ui_handover.md` | Modified: cumulative handover record |
| `docs/ui_po_followup_handover.md` | Added: this comparison/import guide |

The included GRN/signature/Challan files contain earlier local presentation edits omitted from the first delivery as well as the later requested changes; this candidate intentionally includes those related-screen UI dependencies. Isolation testing exposed a 548-pixel mobile overflow when opening the baseline Challan screen; its existing responsive presentation edits are therefore included. Their API methods must be merged against the integration project's current backend, not replaced wholesale.

Excluded: Accounts dashboard, payment screens, WO screens, Status of Supplies screens, `poassignedpreviewhtml.dart`, `quote_pdf.dart`, the broad `test/account_management_preview_test.dart`, `AGENTS.md`, `flutter_01.png`, generated output and all other unlisted files. Those files have pre-existing local work; their presence does not make them part of this handover. The broad test's relevant expectations were updated locally, but the new focused tests provide this batch's commit boundary.

## Interfaces and integration boundary

- Existing public screen constructors/filenames remain stable. No new state-management framework.
- New `PoAssignedFilterDialog({key, required groups, required onReset, required onApply, isPreview = false})`: `groups` is the existing `List<FilterList>`; selections/counts mutate those existing models, while the parent owns reset/apply/refresh. The callbacks are `VoidCallback`. The name is retained even though Issued now reuses it.
- Required existing fields: stable unique order/project/tower IDs, PO number/date/status/reapproval reason, grade/booking type, delivery status, documents, `authorizeFlag`, `grn_active`, signature URL; current filter groups/option IDs/names; GRN number/booking/challan/grade/date/file name.
- Required existing actions: list refresh/date/search/filter, documents, delivery quantity, GRN/Challan navigation, signature view/submit with existing permissions, and current Verify PO editing/upload/assign/vendor quote operations.
- No new fields or backend operations are required. Preserve live endpoint paths, authentication, tokens, payloads and business rules using backend/Postman references.
- API-containing files touched: `porequested.dart`, `podetails.dart`, `grnlistingview.dart`, `signature_dialog.dart`, `accountmanagement.dart`, `chalan_Screen.dart`. Intended runtime changes are presentation/local state only: clearing rows before offset-zero refresh prevents duplicate rows after closing signatures; GRN search uses loaded data; preview guards provide sample options/Issued flags. Challan switches its loading presentation from `CustomLoading` to the existing `AccountLoading`. Live payload construction and signature submission logic remain existing code.

## Demonstration data and requirements

- Existing `useAccountManagementTestData = kDebugMode` configuration is preserved. Preview requests are intercepted locally. Sample vendors, booking types and delivery statuses are explicitly labelled in the filter; preview Issued rows set Issued status and enable the first row's existing GRN action.
- Filter selections/search/reset/apply demonstrate UI interaction; static preview order rows are not actually server-filtered. Local custom units and other previous demonstration lists remain nonpersistent. This is not evidence of live API integration.
- No added assets, fonts, dependencies, lockfile or platform changes. Requires the original handover's shared layout/style/loading/feedback helpers and existing resolved dependencies.
- Installed resolved tests use a newer Dart SDK than the manifest's `<3.0.0` constraint. `--no-pub` results do not establish fresh dependency resolution or a release build. Integration should retain its compatible SDK/dependencies.

## Validation and remaining work

- Isolated verification passed all 9 tests using the previous delivered commit plus only the 12 listed files, with existing resolved dependency metadata copied for `--no-pub`. Included: mobile 390/desktop 1920 Assigned/Issued cards and filters, expanded-only actions, delivery/document/signature dialogs, GRN search/navigation, main/Verified navigation/editing and feedback. This demonstrates no dependency on the other dirty source files for these tested flows.
- The initial 11-file candidate passed 8/9; a mobile Challan overflow identified the missing responsive UI dependency. Including its reviewed presentation-only changes resolved the failure. No application code was changed during handover preparation.
- Selected tracked diff whitespace checks passed. All five primary files retained their existing `AppUrl` reference sequences; GRN fetch and signature submission bodies are unchanged. Challan's fetch only substitutes the loading presentation. Existing Verify PO API methods inspected remain unchanged; modified preview-unit methods are presentation/demo code. A narrow private-key/GitHub/AWS credential pattern scan found no matches in selected files; this is not a complete secret audit.
- No live backend requests, native upload, fresh dependency resolution, release build or screenshot acceptance review is planned for this preparation.
- Source files still combine presentation with existing API code; merge reviewed UI changes into the integration developer's current files. Offline fixtures cannot validate server permissions, persistence or production data lengths/accessibility settings.

## Import this delivery

Only the manifest above is authorized for this delivery on `codex/ui-po-verified-handover`, preserving baseline history. The integration developer should use the exact new hash and comparison link reported in chat, compare `50bc6c792741e1464d9744afce792c0013ff8005..NEW_HASH`, import that delta, and record `NEW_HASH` as the next comparison baseline.
