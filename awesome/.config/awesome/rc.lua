-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local vicious = require("vicious")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify(
      { preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal(
      "debug::error",
      function (err)
         -- Make sure we don't go into an endless error loop
         if in_error then return end
         in_error = true

         naughty.notify({ preset = naughty.config.presets.critical,
                          title = "Oops, an error happened!",
                          text = tostring(err) })
         in_error = false
   end)
end

-- Themes define colours, icons, font and wallpapers.
beautiful.init( awful.util.getdir("config") .. "/themes/theme.lua" )

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
   awful.layout.suit.spiral.dwindle,
   awful.layout.suit.spiral,
   awful.layout.suit.tile,
   awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   awful.layout.suit.fair.horizontal,
}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

separator_default = wibox.widget.textbox(" ░ ")

time_clock = wibox.widget.textclock("%H:%M")

date_clock = wibox.widget.textclock("%A %e %B %Y")

operating_system = wibox.widget.textbox()
vicious.register(operating_system, vicious.widgets.os, "$2")

sound = wibox.widget.textbox()
vicious.register(sound, vicious.widgets.volume, "♫ $1%", 1, "Master")

network = wibox.widget.textbox()
vicious.register(network, vicious.widgets.net, "NET ↧${wlp1s0 down_kb} ↥${wlp1s0 up_kb} (Kb)")

disk = wibox.widget.textbox()
vicious.register(disk, vicious.widgets.fs, "FS / ${/ avail_gb} Gib")

memory = wibox.widget.textbox()
vicious.register(memory, vicious.widgets.mem, "MEM $1% $2/$3 (Mib)")

cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, "CPU ▨$1% ❶$2% ❷$3% ❸$4% ❹$5%")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
   awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            c:emit_signal(
               "request::activate",
               "tasklist",
               {raise = true}
            )
         end
   end),
   awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
   awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
   awful.button({ }, 5, function () awful.client.focus.byidx(-1)
end))

awful.screen.connect_for_each_screen(function(s)
      -- Each screen has its own tag table.
      awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 " }, s, awful.layout.layouts[1])

      -- Create a promptbox for each screen
      s.mypromptbox = awful.widget.prompt()
      -- Create an imagebox widget which will contain an icon indicating which layout we're using.
      -- We need one layoutbox per screen.
      s.mylayoutbox = awful.widget.layoutbox(s)
      s.mylayoutbox:buttons(
         gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end)))
      -- Create a taglist widget
      s.mytaglist = awful.widget.taglist {
         screen  = s,
         filter  = awful.widget.taglist.filter.all,
         buttons = taglist_buttons
      }

      -- Create the wibox
      s.mywibox = awful.wibar({ position = "bottom", screen = s })

      -- Add widgets to the wibox
      s.mywibox:setup {
         layout = wibox.layout.align.horizontal,
         { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
         },
         -- Middle widgets
         wibox.widget({
               visible = false,
               widget = wibox.widget.separator,
         }),
         { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            separator_default,
            cpuwidget,
            separator_default,
            memory,
            separator_default,
            disk,
            separator_default,
            network,
            separator_default,
            sound,
            separator_default,
            operating_system,
            separator_default,
            date_clock,
            separator_default,
            time_clock,
            separator_default,
            s.mylayoutbox,
         },
      }
end)

globalkeys = gears.table.join(
   awful.key(
      {},
      "XF86AudioLowerVolume",
      function () awful.util.spawn("amixer -q -D pulse sset Master 5%-", false) end
   ),

   awful.key(
      {},
      "XF86AudioRaiseVolume",
      function () awful.util.spawn("amixer -q -D pulse sset Master 5%+", false) end
   ),

   awful.key(
      {},
      "XF86AudioPlay", function() awful.util.spawn("playerctl play-pause", false) end
   ),

   awful.key(
      {},
      "XF86AudioNext",
      function() awful.util.spawn("playerctl next", false) end
   ),

   awful.key(
      {},
      "XF86AudioPrev",
      function() awful.util.spawn("playerctl previous", false) end
   ),

   awful.key(
      { modkey, },
      "h",
      hotkeys_popup.show_help,
      {description="show help", group="awesome"}
   ),

   awful.key(
      { modkey, },
      "Right",
      function () awful.client.focus.byidx( 1) end,
      {description = "focus next by index", group = "client"}
   ),

   awful.key({ modkey, },
      "Left",
      function () awful.client.focus.byidx(-1) end,
      {description = "focus previous by index", group = "client"}
   ),

   awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.byidx(  1)    end,
      {description = "swap with next client by index", group = "client"}),
   awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.byidx( -1)    end,
      {description = "swap with previous client by index", group = "client"}),
   awful.key({ modkey,           }, "Tab",
      function ()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
      end,
      {description = "go back", group = "client"}),


   awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
      {description = "open a terminal", group = "launcher"}),
   awful.key({ modkey, "Control" }, "r", awesome.restart,
      {description = "reload awesome", group = "awesome"}),
   awful.key({ modkey, "Shift"   }, "q", awesome.quit,
      {description = "quit awesome", group = "awesome"}),

   awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
      {description = "select next", group = "layout"}),
   awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
      {description = "select previous", group = "layout"}),

   awful.key(
      { modkey },
      "r",
      function () awful.screen.focused().mypromptbox:run() end,
      {description = "run prompt", group = "launcher"}
   ),

   awful.key(
      { modkey },
      "p",
      function() menubar.show() end,
      {description = "show the menubar", group = "launcher"}
   )
)

clientkeys = gears.table.join(
   awful.key(
      { modkey, },
      "f",
      function (c)
         c.fullscreen = not c.fullscreen
         c:raise()
      end,
      {description = "toggle fullscreen", group = "client"}
   ),
   awful.key({ modkey, "Shift"   }, "k",      function (c) c:kill()                         end,
      {description = "close", group = "client"}),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
      {description = "toggle floating", group = "client"}),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
      {description = "move to master", group = "client"}),
   awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
      {description = "move to screen", group = "client"}),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
      {description = "toggle keep on top", group = "client"}),
   awful.key({ modkey,           }, "m",
      function (c)
         c.maximized = not c.maximized
         c:raise()
      end ,
      {description = "(un)maximize", group = "client"}),
   awful.key({ modkey, "Control" }, "m",
      function (c)
         c.maximized_vertical = not c.maximized_vertical
         c:raise()
      end ,
      {description = "(un)maximize vertically", group = "client"}),
   awful.key({ modkey, "Shift"   }, "m",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
         c:raise()
      end ,
      {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
   globalkeys = gears.table.join(
      globalkeys,
      -- View tag only.
      awful.key({ modkey }, "#" .. i + 9,
         function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               tag:view_only()
            end
         end,
         {description = "view tag #"..i, group = "tag"}),
      -- Toggle tag display.
      awful.key({ modkey, "Control" }, "#" .. i + 9,
         function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               awful.tag.viewtoggle(tag)
            end
         end,
         {description = "toggle tag #" .. i, group = "tag"}),
      -- Move client to tag.
      awful.key({ modkey, "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:move_to_tag(tag)
               end
            end
         end,
         {description = "move focused client to tag #"..i, group = "tag"}),
      -- Toggle tag on focused client.
      awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:toggle_tag(tag)
               end
            end
         end,
         {description = "toggle focused client on tag #" .. i, group = "tag"}))
end

clientbuttons = gears.table.join(
   awful.button({ }, 1, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
   end),
   awful.button({ modkey }, 1, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
         awful.mouse.client.move(c)
   end),
   awful.button({ modkey }, 3, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
         awful.mouse.client.resize(c)
   end)
)

-- Set keys
root.keys(globalkeys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
   },

   -- Floating clients.
   { rule_any = {
        instance = {
           "DTA",  -- Firefox addon DownThemAll.
           "copyq",  -- Includes session name in class.
           "pinentry",
        },
        class = {
           "Arandr",
           "Blueman-manager",
           "Gpick",
           "Kruler",
           "MessageWin",  -- kalarm.
           "Sxiv",
           "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
           "Wpa_gui",
           "veromix",
           "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
           "Event Tester",  -- xev.
        },
        role = {
           "AlarmWindow",  -- Thunderbird's calendar.
           "ConfigManager",  -- Thunderbird's about:config.
           "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
   }, properties = { floating = true }},

   -- Add titlebars to normal clients and dialogs
   { rule_any = {type = { "normal", "dialog" }
                }, properties = { titlebars_enabled = false }
   },
}

-- Signal function to execute when a new client appears.
client.connect_signal(
   "manage",
   function (c)
      -- Set the windows at the slave,
      -- i.e. put it at the end of others instead of setting it master.
      -- if not awesome.startup then awful.client.setslave(c) end

      if awesome.startup
         and not c.size_hints.user_position
         and not c.size_hints.program_position then
         -- Prevent clients from being unreachable after screen count changes.
         awful.placement.no_offscreen(c)
      end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal(
   "request::titlebars",
   function(c)
      awful.titlebar(c) : setup
      {
         { -- Left
            { -- Title
               widget = awful.titlebar.widget.titlewidget(c)
            },
            layout  = wibox.layout.flex.horizontal
         },
         layout = wibox.layout.align.horizontal
      }
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
