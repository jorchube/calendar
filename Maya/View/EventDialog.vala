//  
//  Copyright (C) 2011 Jaap Broekhuizen
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

	public class EventDialog : Gtk.Dialog {
		
		Gtk.Container container { get; private set; }

        E.CalComponent cc;
        public E.CalComponent calcomponent { get { return cc; }}
	 
		public EventDialog (Gtk.Window window, E.CalComponent calcomponent) {
		
            cc = calcomponent;

			// Dialog properties
			modal = true;
			window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
			transient_for = window;
			
			// Build dialog
			build_dialog ();
		}
		
		//--- Helpers ---//

		void build_dialog () {
		
		    container = (Gtk.Container) get_content_area ();
		    container.margin_left = 10;
		    container.margin_right = 10;
		    
		    var from_box = make_hbox ();
		    
		    var from = make_label ("From:");
			var from_date_picker = make_date_picker ();
			var from_time_picker = make_time_picker ();
			
			from_box.add (from_date_picker);
			from_box.add (from_time_picker);
		    
		    var switch_label = new Gtk.Label ("All day:");
		    switch_label.margin_right = 20;
		    
		    var allday = new Gtk.Switch ();
		    
		    from_box.add (switch_label);
		    from_box.add (allday);
		    
		    var to = new Gtk.Expander ("<span weight='bold'>To:</span>");
		    to.use_markup = true;
		    to.spacing = 10;
		    to.margin_bottom = 10;
		    
		    var to_box = make_hbox ();
		    
		    var to_date_picker = make_date_picker ();
		    var to_time_picker = make_time_picker ();
		    
		    to_box.pack_start (to_date_picker, false, false, 0);
		    to_box.pack_start (to_time_picker, false, false, 0);
		    
		    to.add (to_box);
		    
		    allday.button_release_event.connect (() => { 
		        from_time_picker.sensitive = !from_time_picker.sensitive;
		        to_time_picker.sensitive = !to_time_picker.sensitive;
		        
		        return false;
		    });
		    
		    var title_location_box = make_hbox ();
		    
		    var title_box = new Gtk.VBox (false, 0);
		    
		    var title_label = make_label ("Title");
		    var title = new Granite.Widgets.HintedEntry ("Name of Event");
		    
		    title_box.add (title_label);
		    title_box.add (title);
		    
		    var location_box = new Gtk.VBox (false, 0);
		    
		    var location_label = make_label ("Location");
	        var location = new Granite.Widgets.HintedEntry ("John Smith OR Example St.");
	        
		    location_box.add (location_label);
		    location_box.add (location);
		    
		    title_location_box.add (title_box);
		    title_location_box.add (location_box);
		    
		    var guest_box = make_vbox ();
		    
		    var guest_label = make_label ("Guests");
			var guest = new Granite.Widgets.HintedEntry ("Name or Email Address");
			
			guest_box.add (guest_label);
			guest_box.add (guest);
			
			var comment_box = new Gtk.VBox (false, 0);
			comment_box.margin_bottom = 20;
			
			var comment_label = make_label ("Comments");
			comment_box.add (comment_label);
			
			var comment = new Gtk.TextView ();
			comment.height_request = 100;
			comment_box.add (comment);
		    
		    container.add (from);
		    container.add (from_box);
		    container.add (to);
		    container.add (title_location_box);
		    container.add (guest_box);
		    container.add (comment_box);
		    
		    add_button (Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
		    add_button ("Create Event", Gtk.ResponseType.APPLY);
		    
		    set_default_response (Gtk.ResponseType.APPLY);
		    show_all();
		}

		Gtk.HBox make_hbox () {
		    
		    var box = new Gtk.HBox (false, 10);
		    box.margin_bottom = 10;
		
		    return box;
		}
		
		Gtk.VBox make_vbox () {
		
		    var box = new Gtk.VBox (false, 0);
		    box.margin_bottom = 10;
		    
		    return box;
		}
		
		Gtk.Label make_label (string text) {
		
		    var label = new Gtk.Label ("<span weight='bold'>" + text + "</span>");
		    label.use_markup = true;
			label.set_alignment (0.0f, 0.5f);
			label.margin_bottom = 10;
		    
		    return label;
		}
		
		Granite.Widgets.DatePicker make_date_picker () {
		    
		    var date_picker = new Granite.Widgets.DatePicker.with_format ("%B %e, %Y");
			date_picker.width_request = 200;
			
			return date_picker;
		}
		
		Granite.Widgets.TimePicker make_time_picker () {
		    
		    var time_picker = new Granite.Widgets.TimePicker.with_format ("%l:%M %p");
		    time_picker.width_request = 80;
		    
		    return time_picker;
		}
		
        //--- Signal Handlers ---//
		
	}
	
	public class AddEventDialog : EventDialog {
	    
	    public AddEventDialog (Gtk.Window window, E.CalComponent event) {
	        
	        base(window, event);
	    
	        // Dialog properties
	        title = "Add Event";
	    }
	}
	
	public class EditEventDialog : EventDialog {
	 
	    public EditEventDialog (Gtk.Window window, E.CalComponent event) {
	        
	        base(window, event);
	        
	        // Dialog Properties
	        title = "Edit Event";
	    }
	}
}

