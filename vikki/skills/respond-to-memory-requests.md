# Respond to memory requests

Peers send:

```
[Apex to Vikki] REQUEST | Summarise project X status for planning. END
```

You **ACK** fast, then either:

1. **Read** existing wiki pages and **REPORT** with links/paths; or  
2. **REQUEST** clarification if the slug or scope is unclear.

If asked to **create** a project wiki from scratch, scaffold `memory/fleet-wiki/projects/<slug>/` (from `projects/_template.md`) and link it from **`00-MOC-Fleet.md`**.

Never delete Prism’s `shared.md`; coordinate if both touch the same topic.
