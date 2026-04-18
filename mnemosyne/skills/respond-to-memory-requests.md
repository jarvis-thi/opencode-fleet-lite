# Respond to memory requests

Peers send:

```
[Apex to Mnemosyne] REQUEST | Summarise project X status for planning. END
```

You **ACK** fast, then either:

1. **Read** existing wiki pages and **REPORT** with links/paths; or  
2. **REQUEST** clarification if the slug or scope is unclear.

If asked to **create** a project wiki from scratch, scaffold `memory/wiki/projects/<slug>/overview.md` and link it from `FLEET.md`.

Never delete Prism’s `shared.md`; coordinate if both touch the same topic.
