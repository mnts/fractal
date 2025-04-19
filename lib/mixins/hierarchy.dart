import 'package:fractal/index.dart';

mixin HierarchyF on EventFractal {
  final sub = MapEvF<HierarchyF>();

  S? getSub<S extends EventFractal>(String name) {
    if (sub[name] case S f) return f;
    HierarchyF? f = this;
    while (f is ExtendableF) {
      f = (f as ExtendableF).extend;
      if (f?.sub[name] case S h) return h;
    }
    return null;
  }

  @override
  consume(f) {
    if (f case NodeFractal node) {
      sub.completeNew(node.name, node);
    }

    if (f case LinkFractal link) {
      if (link.target case NodeFractal node) {
        final current = sub.map[node.name];
        if (current == null || current.createdAt < link.createdAt) {
          sub.complete(node.name, node);
        }
      }
    }

    super.consume(f);
    if (state == StateF.removed) {
      if (to case HierarchyF container) {
        container.sub.notify(this);
      }
    }
  }

  @override
  delete() async {
    await super.delete();
    if (to case HierarchyF node) {
      node.sub.notify(this);
    }
  }
}
