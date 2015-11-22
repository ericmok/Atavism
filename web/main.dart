// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html' as html;
import 'package:atavism_engine/atavism_engine.dart';

void main() {
  html.CanvasElement canvas = html.querySelector('#canvas');

  AtavismEngine atavismEngine = new AtavismEngine(canvas);
  atavismEngine.run();
}
