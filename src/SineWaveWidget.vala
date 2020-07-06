// https://lists.cairographics.org/archives/cairo/2016-October/027791.html

namespace Sinewave {
    public class SineWaveWidget : Gtk.DrawingArea {
        private const int PERIOD = 100;
        private const int NUM_POINTS = 1000;

        static int current_width = -1;
        static int current_height = -1;
        static Cairo.Surface current_source = null;
        static Cairo.Surface current_temp = null;
        static double last_x = -1;
        static double last_y = -1;
        static int redraw_number = 0;

        public SineWaveWidget () {
            add_events (
                Gdk.EventMask.BUTTON_PRESS_MASK |
                Gdk.EventMask.BUTTON_RELEASE_MASK |
                Gdk.EventMask.POINTER_MOTION_MASK
            );
            update ();
            Timeout.add (1000 / 60, update);
        }

        public override bool draw (Cairo.Context context) {
            int width = get_allocated_width ();
            int height = get_allocated_height ();

            update_drawing (width, height, context.get_target ());

            /* Draw the background */
            context.set_source_rgb (1, 1, 1);
            context.paint ();

            /* Draw the content */
            context.set_source_surface (current_source, 0, 0);
            context.paint ();

            redraw_number++;
            return true;
        }


        void update_drawing (int width, int height, Cairo.Surface target) {
            Cairo.Context context;
            int i;

            if (width != current_width || height != current_height) {
                // cairo_surface_destroy(current_source);
                // cairo_surface_destroy(current_temp);

                current_width = width;
                current_height = height;
                current_source = new Cairo.Surface.similar (target, Cairo.Content.COLOR, NUM_POINTS, height);
                current_temp = new Cairo.Surface.similar (target, Cairo.Content.COLOR, NUM_POINTS, height);

                context = new Cairo.Context (current_source);

                /* Redraw everything */

                /* Draw the background */
                context.set_source_rgb (1, 1, 1);
                context.paint ();

                /* Draw a moving sine wave */
                context.set_source_rgb (0.5, 0.5, 0);
                context.move_to (0, sine_to_point (0 + redraw_number, width, height));
                for (i = 1; i < NUM_POINTS; i++) {
                    context.line_to (i, sine_to_point (i + redraw_number, width, height));
                }
                context.get_current_point (out last_x, out last_y);
                context.stroke ();

                // cairo_destroy(context);
            } else {
                Cairo.Surface temp;

                /* Move everything left and add a new data point */
                context = new Cairo.Context (current_temp);

                /* Scroll */
                context.set_source_surface (current_source, -1, 0);
                context.paint ();
                context.set_source_rgb (1, 1, 1);
                context.rectangle (NUM_POINTS - 1, 0, 1, height);
                context.fill ();

                /* Add new point */
                context.set_source_rgb (0.5, 0.5, 0);
                context.move_to (last_x - 1, last_y);
                context.line_to (NUM_POINTS - 1, sine_to_point (NUM_POINTS + redraw_number, width, height));
                context.get_current_point (out last_x, out last_y);
                context.stroke ();

                // cairo_destroy(context);

                /* Swap surfaces */
                temp = current_temp;
                current_temp = current_source;
                current_source = temp;
            }
        }

        bool update () {
            queue_draw ();
            return true;
        }

        inline double sine_to_point (int x, int width, int height) {
            return (height / 2.0) * Math.sin (x * 2 * Math.PI / PERIOD) + (height / 2);
        }
    }
}
