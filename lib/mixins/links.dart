import '../models/index.dart';

mixin WithLinksF on EventFractal {
  final linksIn = <LinkFractal>[];
  final linksOut = <LinkFractal>[];

  addLink(LinkFractal link) {
    if ((link.to) == this && !linksOut.contains(link)) {
      linksOut.add(link);
    }
    if ((link.target) == this && !linksIn.contains(link)) {
      linksIn.add(link);
    }
    notifyListeners();
  }

  removeConnection(LinkFractal link) {
    linksIn.remove(link);
    linksOut.remove(link);
  }
}
