# DRAS MVP Plan - Government/Institutional Design

## Project Overview
Modernizing the DRAS (DMMHs ressursadministrasjonssystem) with a Phoenix LiveView application that addresses the key pain points identified in the current system.

## Completed Steps
- [x] Generate Phoenix LiveView project `dras_mvp`
- [x] Start server for development
- [x] Replace home page with government/institutional design mockup
- [x] Create database migrations for core entities:
  - Academic years with status tracking
  - Courses with metadata
  - Staff with roles and assignments
  - Resource allocations
- [x] Implement Academic Year Management LiveView:
  - Clear year selection interface
  - Automatic year progression features
  - Status indicators for setup completion
- [x] Style layouts with government/institutional design:
  - Update app.css with professional theme
  - Modify root.html.heex and Layouts.app
  - Ensure accessibility standards
- [x] Build Course Management system:
  - Course listing with search/filter
  - Course creation with validation
  - Bulk operations support
- [x] Create Staff Assignment interface:
  - Drag-and-drop assignment feel
  - Real-time updates via PubSub
  - Workload visualization
- [x] Implement intelligent CSV import:
  - Smart parser with error suggestions
  - Preview and validation before import
  - Progress tracking
- [x] Build reporting dashboard:
  - Resource allocation overview
  - Export to Excel/PDF
  - Visual charts and metrics
- [x] Final testing and verification

## Design Goals
- Professional government/institutional appearance
- Structured layouts with clear hierarchies
- High accessibility standards
- Reliable data validation and error handling
- Streamlined workflows replacing manual CSV processes

## MVP Successfully Completed!
The DRAS MVP now provides a modern, accessible interface for academic resource administration that addresses the key pain points of the original system.

