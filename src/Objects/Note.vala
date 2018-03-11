/*-
 * Copyright (c) 2018-2018 Artem Anufrij <artem.anufrij@live.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * The Noise authors hereby grant permission for non-GPL compatible
 * GStreamer plugins to be used and distributed together with GStreamer
 * and Noise. This permission is above and beyond the permissions granted
 * by the GPL license by which Noise is covered. If you modify this code
 * you may extend this exception to your version of the code, but you are not
 * obligated to do so. If you do not wish to do so, delete this exception
 * statement from your version.
 *
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 */

namespace TrimDown.Objects {
    public class Note : GLib.Object {
        public signal void renamed (string title);
        public signal void removed ();

        public string title { get; set; }

        public Chapter parent { get; private set; }

        string content_path;

        public Note (Chapter chapter, string title) {
            this.parent = chapter;
            this.title = title;

            content_path = Path.build_filename (parent.notes_path, title);

            load_properties ();
        }

        private void load_properties () {
            if (!FileUtils.test (content_path, FileTest.EXISTS)) {
                try {
                    FileUtils.set_contents (content_path, "");
                } catch (Error err) {
                    warning (err.message);
                    return;
                }
            }
        }

        public string get_content () {
            string content = "";
            try {
                FileUtils.get_contents (content_path, out content);
            } catch (Error err) {
                    warning (err.message);
            }
            return content;
        }

        public bool save_content (string content) {
            try {
                FileUtils.set_contents (content_path, content);
            } catch (Error err) {
                    warning (err.message);
                return false;
            }
            return true;
        }

        public bool rename (string new_title) {
            var new_path = Path.build_filename (parent.notes_path, new_title);

            if (FileUtils.test (new_path, FileTest.EXISTS)) {
                return false;
            }

            FileUtils.rename (content_path, new_path);
            title = new_title;
            content_path = new_path;

            renamed (title);
            return true;
        }

        public bool trash () {
            File file = File.new_for_path (content_path);
            try {
                if (file.trash ()) {
                    removed ();
                }
            } catch (Error err) {
                warning (err.message);
                return false;
            }

            return true;
        }
    }
}