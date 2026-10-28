# Stoat integration for Garry's Mod

Transmits GMod chat to Stoat and vice-versa.

## Dependencies

- [GWSockets](https://github.com/FredyH/GWSockets/releases/)
- [CHTTP](https://github.com/timschumi/gmod-chttp/releases)

### Installation guide
1. Put dependencies into `garrysmod/lua/bin` (create if directory does not exist).
2. Then download the addon and unpack to `garrysmod/addons`. (`git clone` also works)
3. Finally, edit `gmod_stoat_relay/lua/cl_config.lua` and `gmod_stoat_relay/lua/sv_config.lua` to configure the addon. 
4. After that you should do a full server restart and voila, it works!
