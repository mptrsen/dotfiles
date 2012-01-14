--[[
Ring Meters by londonali1010 (2009)
 
This script draws percentage meters as rings. It is fully customisable; all options are described in the script.
 
To call this script in Conky, use the following (assuming that you save this script to ~/scripts/rings.lua):
    lua_load ~/scripts/rings-v1.2.1.lua
    lua_draw_hook_pre ring_stats
 
]]

-- Background settings
corner_r=20
main_bg_colour=0x060606
main_bg_alpha=0.0
-- Ring color settings
ring_background_color = 0x000000
ring_background_alpha = 0.3
ring_foreground_color = 0x909090
ring_foreground_alpha = 1
-- Rings settings
settings_table = {
   --[[ {
        name='time',
        arg='%S',
        max=60,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=580, y=75,
        radius=55,
        thickness=4,
        start_angle=-58,
        end_angle=58
    },
    {
        name='time',
        arg='%I.%M',
        max=12,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=580, y=75,
        radius=55,
        thickness=12,
        start_angle=-178,
        end_angle=-62
    },
    {
        name='time',
        arg='%M.%S',
        max=60,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=580, y=75,
        radius=55,
        thickness=8,
        start_angle=62,
        end_angle=178
    },]]
    {
        name='battery_percent',
        arg='',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=100, y=150,
        radius=60,
        thickness=23,
        start_angle=-160,
        end_angle=160
    },
    --[[{
        name='cpu',
        arg='cpu4',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=50, y=55,
        radius=23,
        thickness=3,
        start_angle=-180,
        end_angle=0
    },
    {
        name='cpu',
        arg='cpu3',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=50, y=55,
        radius=27,
        thickness=3,
        start_angle=-180,
        end_angle=0
    },
    {
        name='cpu',
        arg='cpu2',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=50, y=55,
        radius=31,
        thickness=3,
        start_angle=-180,
        end_angle=0
    },
    {
        name='cpu',
        arg='cpu1',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=50, y=55,
        radius=35,
        thickness=3,
        start_angle=-180,
        end_angle=0
    },
    {
        name='memperc',
        arg='',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        x=190, y=55,
        radius=32,
        thickness=10,
        start_angle=-180,
        end_angle=-0
    },
    {
        name='fs_used_perc',
        arg='/',
        max=100,
        bg_colour=ring_background_color,
        bg_alpha=ring_background_alpha,
        fg_colour=ring_foreground_color,
        fg_alpha=ring_foreground_alpha,
        g_alpha=ring_foreground_alpha,
        x=320, y=55,
        radius=32,
        thickness=7,
        start_angle=-10,
        end_angle=120
    },]]
}
 
require 'cairo'
 
local function rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end
 
local function draw_ring(cr,t,pt)
    local w,h=conky_window.width,conky_window.height
 
    local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
    local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']
 
    local angle_0=sa*(2*math.pi/360)-math.pi/2
    local angle_f=ea*(2*math.pi/360)-math.pi/2
    local t_arc=t*(angle_f-angle_0)
 
    -- Draw background ring
 
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
    cairo_set_line_width(cr,ring_w)
    cairo_stroke(cr)
 
    -- Draw indicator ring
 
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
    cairo_stroke(cr)        
end
 
local function conky_ring_stats()
    local function setup_rings(cr,pt)
        local str=''
        local value=0
 
        str=string.format('${%s %s}',pt['name'],pt['arg'])
        str=conky_parse(str)
 
        value=tonumber(str)
        if value == nil then value = 0 end
        pct=value/pt['max']
 
        draw_ring(cr,pct,pt)
    end
 
    if conky_window==nil then return end
    local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
 
    local cr=cairo_create(cs)    
 
    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)

    if update_num>1 then
        for i in pairs(settings_table) do
            setup_rings(cr,settings_table[i])
        end
    end
    cairo_destroy(cr)
end

--[[ This is a script made for draw a transaprent background for conky ]]

local function conky_draw_bg()
    if conky_window==nil then return end
    local w=conky_window.width
    local h=conky_window.height
    local cs=cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
    local cr=cairo_create(cs)
--    local thick=2
 
    cairo_move_to(cr,corner_r,0)
    cairo_line_to(cr,w-corner_r,0)
    cairo_curve_to(cr,w,0,w,0,w,corner_r)
    cairo_line_to(cr,w,h-corner_r)
    cairo_curve_to(cr,w,h,w,h,w-corner_r,h)
    cairo_line_to(cr,corner_r,h)
    cairo_curve_to(cr,0,h,0,h,0,h-corner_r)
    cairo_line_to(cr,0,corner_r)
    cairo_curve_to(cr,0,0,0,0,corner_r,0)
    cairo_close_path(cr)
 
    cairo_set_source_rgba(cr,rgb_to_r_g_b(main_bg_colour,main_bg_alpha))
    --cairo_set_line_width(cr,thick)
    --cairo_stroke(cr)
    cairo_fill(cr)
    cairo_destroy(cr)
end

function conky_main()
    conky_draw_bg()
    conky_ring_stats()
end
