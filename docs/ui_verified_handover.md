# First UI handover: Accounts → PO Status → Verified

Status: first UI handover authorized on 2026-11-05. The delivery identifier is the Git commit containing this guide; its exact hash and verified push result are reported in the handover chat.

## Repository and comparison baseline

- Remote: https://github.com/AmaanStallion/UI_Enhancement.git (`origin`).
- User explicitly chose a public repository, overriding the original private-repository requirement. Publishing the selected handover together with the existing baseline history was explicitly authorized on 2026-11-05.
- Intended integration developer: `krushang-stallion`. Public read access needs no invitation; no write/admin access has been granted.
- Delivery branch: `codex/ui-po-verified-handover`.
- Local baseline: `d2a34e513ce21815c77b6cd28a2ad1c85f3d4866`.
- Previous imported handover commit: none recorded. Delivery commit: resolve `git rev-parse HEAD` after checking out this delivery; use the exact hash reported in the handover chat for import tracking.
- This authorized delivery includes the existing initial baseline history, not just the changed UI files. Local history is preserved without force-pushing or reinitializing Git.

## Included user flow and visible behaviour

1. Account Management main screen: outlined status groups, compact tiles with hover feedback, existing navigation/tower selector/payment footer, matching skeleton loader.
2. Purchase Order Status → Verified: five-field collapsed summaries with light badges; arrow-only expand/collapse; View Doc acts separately; tapping either card body opens Verify PO.
3. Verify PO: black two-column summary, compact editable controls and two-line labels, editable date/quantity/unit/price, existing amount calculation, uploads and two-line remarks, check/uncheck confirmation, assignment/vendor-quote UI and responsive quote loading dialog.

No new save/API endpoint has been implemented. Local custom units and sample requirement/slab lists are demonstration behaviour, not server operations.

## Authorized changed/added files

Application files (paths relative to `lib/ui/views/accountmanagement/`):

| File | Purpose |
| --- | --- |
| `accountmanagement.dart` | Main screen and its existing navigation |
| `porequested.dart` | Shared PO list; Verified-specific collapse/navigation behaviour |
| `podetails.dart` | Verify PO details/form and related dialogs |
| `account_management_layout.dart` | New shared responsive presentation helpers |
| `account_management_style.dart` | New shared theme, cards, buttons and dialogs |
| `account_management_loading.dart` | New loading presentation, including `AccountMainSkeleton` |
| `po_action_feedback.dart` | New pointer feedback wrapper |
| `account_management_fixtures.dart` | Existing fixture flag adjustments exposing demonstration states |

Tests/documentation:

- `test/po_verified_handover_test.dart` — new focused, network-blocked main/Verified flow checks at 390 and 1920 widths.
- `test/po_action_feedback_test.dart` — new standalone feedback check.
- `docs/ui_verified_handover.md` — this integration guide.
- `docs/ui_handover.md` — full working handover record and review limitations.

No renames or deletions are proposed. No dependency, font, asset, lockfile or platform configuration changes are proposed.

## Shared-file boundaries and exclusions

- The main screen also displays WO/payment tiles. Their appearance belongs to that parent screen; their backend operations are unchanged.
- `porequested.dart` contains Assigned/Issued branches as well as Verified, and its pre-existing diff includes presentation edits in those branches. These are physically shared source, not isolated modules. The reviewed 12-file batch includes this shared source; the Verified collapse/navigation code is explicitly gated to Verified. Preserve the integration project's newer backend and other-state logic when merging.
- `podetails.dart` also contains other states. Later field/sizing changes are gated to `poId == 'Verified'`; earlier presentation edits share the file. Do not replace integration code wholesale.
- Other dirty files (Accounts dashboard, WO, payment screens, signatures, GRN/challan screens, etc.) remain outside this proposed first batch unless a concrete dependency is identified and separately recorded.
- The broad `test/account_management_preview_test.dart` exercises those excluded screens; it remains a development regression test, outside this focused commit. Use the focused handover tests above for this file set.
- Exclude `flutter_01.png`, local logs, environment/credential files, build output and caches. `AGENTS.md` remains separate project guidance, not a runtime requirement.

## Existing dependencies needed for first import

The initial baseline already contains preview support, routes, models and utilities. The receiving project may not have them:

- `account_management_preview.dart`, `account_management_preview_network.dart`, `account_management_preview_document.dart` and the fixture file.
- `lib/main.dart`: `/poRequestedViewScreen` route; `NotificationArgs` with project/tower context and `flagRedirect: 'Verified'`.
- Parent navigation in `lib/ui/views/workprogess/workprogess_list.dart`.
- Existing PO/order/default-request/grade-description models and shared utilities/widgets referenced by the three primary screens.
- Existing `HelveticaNeue` font declarations, loading animation assets, upload/PDF images, `shimmer`, `lottie`, `flutter_typeahead`, `search_choices`, `file_picker`, and the other existing manifest dependencies.

Use the receiving project's compatible dependencies/configuration. This workspace's manifest declares Dart `<3.0.0`, while its installed resolved test environment uses Dart 3.12.2. Passing `--no-pub` tests does not establish a fresh dependency resolution or release-build result. No SDK/dependency upgrade was made for this handover.

## UI interfaces and integration requirements

- Existing screen constructors and filenames are retained: `AccountManagementView`, `PoRequestedView`, `PoDetails`.
- Shared helper APIs are listed in `docs/ui_handover.md`; new `AccountMainSkeleton({key})` is presentation only. Private form/navigation helpers are not a new integration framework.
- Supply real project/tower/order IDs; PO number/creation date, status/reapproval reason, booking type, delivery status and document lists for cards. Stable unique order IDs preserve expansion state.
- Supply order details, editable description/requirement text, quantity, unit name/ID, price, date, brand, remarks and existing permission/status flags for Verify PO.
- Preserve existing actions: refresh/search/filter/pagination, document open/upload/remove, verify/unverify, assign and request vendor quotation. Backend/Postman collections remain the API authority.
- Confirm that the actual Verify PO save/assign flow persists text, quantity, price, date and remarks edits. The UI does not add form fields to an assignment/vendor-quote payload that did not already contain them.
- `SELECT SLAB` maintains its separate selected-ID collection; a typed/chosen Requirement For text suggestion does not create a slab or silently modify that collection.
- Map unit/type/slab selections to real IDs. `preview-unit-*`, `preview-type-*`, and `preview-slab-*` values must never be submitted as real records.

## Demo versus production wiring

- Existing `useAccountManagementTestData = kDebugMode` is unchanged. Debug mode uses local fixtures; the existing adapter overrides `post` and can return generic local success.
- Preview-only Add Custom Unit is supported on desktop/mobile. Request PO has a separate existing backend custom-unit implementation; it was deliberately not wired into Verify PO, per the user's instruction.
- Existing parent preview navigation bypasses Accounts module assignment; preserve the receiving project's real access checks. Do not transfer demonstration access behaviour as production permission logic.
- The three primary screens' active `AppUrl` reference sequences match the initial baseline. Central endpoint/authentication/token utilities and request schemas were not changed during handover preparation. Presentation and moved UI navigation still coexist with API methods in those files.
- Preview configuration and backend wiring must be handled in a separate integration change by the developer, not silently disabled or replaced as part of this UI delivery.

## Checks and limitations

- Current working-tree offline regression: 47 tests passed at desktop width 1920 and 47 at mobile width 390 (`account_management_preview_test.dart` plus `po_action_feedback_test.dart`).
- Focused handover tests: 5 passed, including four network-blocked main/Verified checks across both widths and one feedback test.
- `git diff --check` passed. Read-only inspection found an empty remote and existing `AmaanStallion` credentials via Git Credential Manager. No passwords/tokens were printed.
- A narrow tracked-file scan found no matching private-key/GitHub/AWS credential patterns; it is not a complete secret audit. Firebase client configuration files already exist in the baseline and must be included in the publication review of that full baseline.
- Baseline-only verification: the same 5 focused tests passed in a separate copy of the original baseline plus only the proposed 12 files, using the installed resolved dependency metadata with its project path remapped. This excludes unrelated dirty screen changes; it is not a fresh dependency resolution or release build. Initial attempts in a temporary directory could not locate the pubspec; the shared writable copy ran successfully.
- User approved this 12-file batch, delivery branch and publication of the existing baseline history on 2026-11-05. No live backend requests, fresh dependency resolution, release build, file-picker upload or full visual acceptance check was performed.
- Prior generic helper wrapping/loading lifecycle concerns remain recorded in `docs/ui_handover.md`. Their presence is not resolved merely by passing fixture-based tests.

## Import and next handover

1. Use the exact delivery commit hash reported in the handover chat. A branch name alone is not a stable import identifier.
2. Compare the three primary screens and shared helpers to the baseline and merge UI changes onto the current backend project. Do not import unrelated working-tree changes or replace current API methods with older baseline implementations.
3. Confirm real-data permissions, IDs, errors/loading, uploads and save/approve/assign behaviour against backend/Postman references.
4. Record the exact imported commit as the next comparison baseline. Later handovers must be compared to that commit, not repeatedly to the initial baseline.
