# Project Plan for DrasMvp

## Overview
- Create a Phoenix LiveView project that uses Tailwind CSS, esbuild, and daisyUI.
- Use SQLite as the database adapter.
- Implement routes for main pages with LiveView.
- Update root layout and app layout to match design with forced theme.
- Replace placeholder home page route with real LiveView route.
- Fully style inputs and text containers with tailwind CSS classes for proper contrast.
- Use `<Layouts.app flash={@flash}>...</Layouts.app>` wrapping for LiveViews and templates.
- Start the server immediately after creating the plan.md to visualize changes.
- Do not use deprecated layout options or flash_group outside layouts.ex.
- Avoid re-indexing latest files, only index stale or missing files when needed.

## Steps
- [ ] Generate Phoenix LiveView project with SQLite and no gettext.
- [ ] Add and configure Tailwind, esbuild, and dependencies.
- [ ] Start server to confirm setup.
- [ ] Replace `lib/dras_mvp_web/controllers/page_html/home.html.heex` with static mockup (full design).
- [ ] Create main LiveView and template, wrapped with `<Layouts.app>`.
- [ ] Update `lib/dras_mvp_web/components/layouts/root.html.heex` forcing theme and styles.
- [ ] Update `lib/dras_mvp_web/components/layouts.ex` for app layout design and remove default elements.
- [ ] Update `assets/css/app.css` for theme matching design and daisyUI plugin config.
- [ ] Update router to remove placeholder home page route and add real routes.
- [ ] Start server and visit app for verification.
- [ ] Plan debugging and next feature steps.

Should I proceed with this plan?
