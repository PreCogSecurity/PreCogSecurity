#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import os

import webapp2

class MainHandler(webapp2.RequestHandler):
    def get(self):
        self.response.write('Hello world!')

# SECURITY: debug=True must never reach a deployed instance. webapp2's
# debug mode answers unhandled exceptions with a full traceback that includes
# local variable values and source snippets (CWE-209), which on a public
# endpoint hands an attacker the source tree and any configuration that leaked
# into a frame. Opt in explicitly, and only for local development.
app = webapp2.WSGIApplication([
    ('/', MainHandler)
], debug=os.environ.get('APP_ENV', '') == 'dev')
