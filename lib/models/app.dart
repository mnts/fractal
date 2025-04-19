import 'package:color/color.dart';
import 'package:fractal/index.dart';
import 'package:yaml/yaml.dart';

class AppCtrl<T extends NodeFractal> extends NodeCtrl<T> {
  AppCtrl({
    super.name = 'app',
    required super.make,
    required super.extend,
    super.attributes = const [
      //Attr('domain', String),
    ],
  });

  @override
  hashData(m) {
    return ['app', m['name'], m['to']];
  }
}

class AppFractal extends NodeFractal {
  static final controller = AppCtrl(
    extend: NodeFractal.controller,
    make: (d) => switch (d) {
      MP() => AppFractal.fromMap(d),
//      String s => AppFractal(),
      _ => throw (),
    },
  );

  static late AppFractal active;

  bool dark = false;
  bool isGated = true;

  @override
  get hashData => ['app', name, to?.key ?? ''];

  @override
  AppCtrl get ctrl => controller;

  FractalSkin get skin => FractalSkin(
        color: color,
      );

  /*
  List<ScreenFractal> get myScreens => screens
      .where((screen) => !((screen.audience == Audience.authenticated &&
              UserFractal.active.isNull) ||
          (screen.audience == Audience.notAuthenticated &&
              !UserFractal.active.isNull)))
      .toList();
  */

  static bool defaultOnlyAuthorized = true;

  bool hideAppBar = false;
  final bool onlyAuthorized;
  bool enableTerminal = false;

  openProfile(UserFractal profile) {
    profile;
  }

  //late final List<String> createProfileFields;

  //Widget Function()? mainGate;
  //List<AuthFractalImpl> auths = [];
  //List<IconButton Function(BuildContext ctx)> actions = [];

  Color color;
  AppFractal({
    //this.mainGate,
    //this.auths = const [],
    //this.actions = const [],
    bool? onlyAuthorized,
    //this.createProfileFields = const ['first_name', 'last_name', 'email'],
    //this.repoUrl,
    this.hideAppBar = false,
    Color? color,
    //this.screens = const [],
    bool? isGated,
    this.enableTerminal = false,
    required super.name,
    super.to,
    super.extend,
  })  : onlyAuthorized = onlyAuthorized ?? defaultOnlyAuthorized,
        isGated = isGated ?? defaultOnlyAuthorized,
        color = color ?? defaultColor {
    _construct();
  }

  static var defaultColor = Color.rgb(10, 20, 250);
  //static var defaultColor = Color.rgb(37, 20, 10);
  //static var defaultColor = Color.rgb(250, 105, 5);

  static late AppFractal main;

  static final storage = MapEvF<AppFractal>();
  _construct() {
    if (to != null) storage[name] = this;
  }

  @override
  consume(event) {
    /*
    if (event case DomainFractal node) {
      domains.complete(node.domain, node);
    }
    */
    super.consume(event);
  }

  //final domains = MapEvF<DomainFractal>();

  YamlMap repo = YamlMap();

  AppFractal.fromMap(MP d)
      : onlyAuthorized = defaultOnlyAuthorized,
        isGated = defaultOnlyAuthorized,
        color = d['color'] == null
            ? defaultColor
            : Color.hex(
                d['color'],
              ),

        /*(
          publicKey: d['public_key'],
          privateKey: d['private_key'],
        )*/

        super.fromMap(d) {
    _construct();
  }

  navigate() {}

  static final ctrls = <FractalCtrl>[
    AppFractal.controller,
  ];

  String get domain {
    String domain = name;
    if (to case AppFractal app) {
      domain += '.${app.name}';
    }
    return domain;
  }

  static Future<int> init() async {
    for (final el in ctrls) {
      await el.init();
    }

    //main.hash = EventFractal.makeHash(main.hashData);
    //main.complete();

    return 1;
  }

  static bool autoCreate = true;

  @override
  onWrite(f) async {
    switch (f.attr) {
      case 'color':
        var hex = '#${int.parse(f.content).toRadixString(16).substring(2)}';
        color = Color.hex(hex);
    }

    return await super.onWrite(f);
  }

  static Future<AppFractal?> byDomain(String domain) async {
    final se = domain.split('.');
    AppFractal? app;
    int i = 0;
    for (i = 0; i < se.length - 1; i++) {
      final name = se.sublist(i).join('.');
      app = AppFractal.storage[name];
      if (app != null) break;
    }

    if (app == null) {
      if (autoCreate) {
        app = main;
      } else {
        return null;
      }
    }

    final names = se.sublist(0, i).reversed.skip(1);
    for (final name in names) {
      var subApp = app!.sub[name];
      if (subApp == null || subApp is! AppFractal) {
        if (autoCreate) {
          subApp = await AppFractal.controller.put({
            'name': name,
            'kind': 3,
            'extend': app.hash,
            'owner': '',
          });
          subApp.synch();
        } else {
          break;
        }
      }
      app = subApp;
    }
    return app;
  }
}

//OpenProfile get openProfile => AppFractal.active.openProfile;
