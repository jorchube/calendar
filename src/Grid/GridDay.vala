//
//  Copyright (C) 2011-2012 Maxwell Barvian
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Maya.View {

/**
 * Represents a single day on the grid.
 */
public class GridDay : Gtk.EventBox {

    /*
     * Event emitted when the day is double clicked or the ENTER key is pressed.
     */
    public signal void on_event_add (DateTime date);

    public DateTime date { get; private set; }
    // We need to know if it is the first column in order to not draw it's left border
    public bool is_first_column = false;
    Gtk.Overlay overlay;
    Gtk.Label label;
    Gtk.Grid container_grid;
    VAutoHider event_box;
    Gee.List<EventButton> event_buttons;

    private static const int EVENT_MARGIN = 3;

    public GridDay (DateTime date) {
        this.date = date;
        event_buttons = new Gee.ArrayList<EventButton>();

        overlay = new Gtk.Overlay ();
        container_grid = new Gtk.Grid ();
        label = new Gtk.Label ("");
        event_box = new VAutoHider ();
        event_box.expand = true;

        // EventBox Properties
        can_focus = true;
        events |= Gdk.EventMask.BUTTON_PRESS_MASK;
        events |= Gdk.EventMask.KEY_PRESS_MASK;
        events |= Gdk.EventMask.SMOOTH_SCROLL_MASK;
        var style_provider = Util.Css.get_css_provider ();
        get_style_context ().add_provider (style_provider, 600);
        get_style_context ().add_class ("cell");

        label.halign = Gtk.Align.END;
        label.get_style_context ().add_provider (style_provider, 600);
        label.name = "date";

        Util.set_margins (label, EVENT_MARGIN, EVENT_MARGIN, 0, EVENT_MARGIN);
        Util.set_margins (event_box, 0, EVENT_MARGIN, EVENT_MARGIN, EVENT_MARGIN);
        container_grid.attach (label, 0, 0, 1, 1);
        container_grid.attach (event_box, 0, 1, 1, 1);

        add (overlay);
        overlay.add (container_grid);
        container_grid.show_all ();

        // Signals and handlers
        button_press_event.connect (on_button_press);
        key_press_event.connect (on_key_press);
        scroll_event.connect ((event) => {return GesturesUtils.on_scroll_event (event);});
        container_grid.draw.connect (on_draw);
    }

    public void add_event_button (EventButton button) {
        if (button.get_parent () != null)
            button.unparent ();
        event_box.add (button);
        button.show_all ();

        event_buttons.add (button);
        event_buttons.sort (EventButton.compare_buttons);
    }

    public void remove_event (E.CalComponent comp) {
        foreach(var button in event_buttons) {
            if(comp == button.comp) {
                event_buttons.remove (button);
                destroy_button (button);
                break;
            }
        }
    }

    public void clear_events () {
        foreach(var button in event_buttons) {
            destroy_button (button);
        }

        event_buttons.clear ();
    }

    private void destroy_button (EventButton button) {
        button.set_reveal_child (false);
        Timeout.add (button.transition_duration, () => {
            button.destroy ();
            return false;
        });
    }

    public void sensitive_container (bool sens) {
        container_grid.sensitive = sens;
    }

    public void update_date (DateTime date) {
        this.date = date;
        label.label = date.get_day_of_month ().to_string ();
    }

    public void set_selected (bool selected) {
        if (selected) {
            set_state_flags (Gtk.StateFlags.SELECTED, true);
        } else {
            set_state_flags (Gtk.StateFlags.NORMAL, true);
        }
    }

    private bool on_button_press (Gdk.EventButton event) {
        if (event.type == Gdk.EventType.2BUTTON_PRESS && event.button == Gdk.BUTTON_PRIMARY)
            on_event_add (date);

        grab_focus ();
        return false;
    }

    private bool on_key_press (Gdk.EventKey event) {
        if (event.keyval == Gdk.keyval_from_name("Return") ) {
            on_event_add (date);
            return true;
        }

        return false;
    }

    private bool on_draw (Gtk.Widget widget, Cairo.Context cr) {
        Gtk.Allocation size;
        widget.get_allocation (out size);

        // Draw left and top black strokes
        if (is_first_column == true && Settings.SavedState.get_default ().show_weeks == false) {
            cr.move_to (0.5, 0.5);
        } else {
            cr.move_to (0.5, size.height); // start in bottom left. 0.5 accounts for cairo's default stroke offset of 1/2 pixels
            cr.line_to (0.5, 0.5); // move to upper left corner
        }

        cr.line_to (size.width + 0.5, 0.5); // move to upper right corner

        cr.set_source_rgba (0.0, 0.0, 0.0, 0.25);
        cr.set_line_width (1.0);
        cr.set_antialias (Cairo.Antialias.NONE);
        cr.stroke ();

        // Draw inner highlight stroke
        cr.rectangle (1, 1, size.width - 1, size.height - 1);
        cr.set_source_rgba (1.0, 1.0, 1.0, 0.2);
        cr.stroke ();
        return false;
    }

}

}
