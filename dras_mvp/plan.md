# DRAS MVP Plan - Government/Institutional Design

## Project Overview
Modernizing the DRAS (DMMHs ressursadministrasjonssystem) with a Phoenix LiveView application that addresses the key pain points identified in the current system.

## Completed Steps
- [x] Generate Phoenix LiveView project `dras_mvp`
- [x] Start server for development
- [ ] Replace home page with government/institutional design mockup
- [ ] Create database migrations for core entities:
  - Academic years with status tracking
  - Courses with metadata
  - Staff with roles and assignments
  - Resource allocations
- [ ] Implement Academic Year Management LiveView:
  - Clear year selection interface
  - Automatic year progression features
  - Status indicators for setup completion
- [ ] Build Course Management system:
  - Course listing with search/filter
  - Course creation with validation
  - Bulk operations support
- [ ] Create Staff Assignment interface:
  - Drag-and-drop assignment feel
  - Real-time updates via PubSub
  - Workload visualization
- [ ] Implement intelligent CSV import:
  - Smart parser with error suggestions
  - Preview and validation before import
  - Progress tracking
- [ ] Build reporting dashboard:
  - Resource allocation overview
  - Export to Excel/PDF
  - Visual charts and metrics
- [ ] Style layouts with government/institutional design:
  - Update app.css with professional theme
  - Modify root.html.heex and Layouts.app
  - Ensure accessibility standards
- [ ] Final testing and verification

## Design Goals
- Professional government/institutional appearance
- Structured layouts with clear hierarchies
- High accessibility standards
- Reliable data validation and error handling
- Streamlined workflows replacing manual CSV processes
</TOOLMETA>
