#Active Record Lite

An exercise in rebuilding the core classes and methods of Active Record in order to understand exactly how this model uses meta-programming and SQL-wrapping to ease the interface with database querying.

- Rails's attribute_accessible macro is re-written from scratch.
- Core methods `.all`, `.find`, `.where`, and `#save` are rewritten by executing the query with SQLite3 gem.
- `.belongs_to`, `.has_many`, and `.has_one_through` macros are all rewritten in the same manner.
