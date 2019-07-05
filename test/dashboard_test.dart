import 'package:flutter/material.dart';
import 'package:flutter_campus_connected/models/dashboard_item.dart';
import 'package:flutter_campus_connected/pages/dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helper.dart';

void main() {

  //Icons Tests
  final find_account_circle_Icon = find.byIcon(Icons.account_circle);
  final find_person_Icon = find.byIcon(Icons.person);
  final find_event_available_Icon = find.byIcon(Icons.event_available);
  final find_event_Icon = find.byIcon(Icons.event);
  final find_question_answer_Icon = find.byIcon(Icons.question_answer);
  final find_exit_to_app_Icon = find.byIcon(Icons.exit_to_app);
  final find_settings_Icon = find.byIcon(Icons.settings);

  checkListTitle(ListTile item, String title) {
    expect(item.title is Text, true);
    final Text text = item.title as Text;
    expect(text.data == title, true);
  }

  group('Dashboard test', () {
    test('Dashboard_item test', () {
      final entity = DashboardItem('test', 'test.png');
      expect(entity, isNotNull);
      expect(entity.photoUrl, isNotEmpty);
      expect(entity.displayName, isNotEmpty);

      expect(entity.displayName, equals('test'));
      expect(entity.photoUrl, 'test.png');
    });


    testWidgets('Dashboard widget test', (WidgetTester tester) async {
      final StatefulWidget dashboard = Dashboard();
      final curr = TestHelper.buildPage(dashboard);
      await tester.pumpWidget(curr);
      //state
      final DashboardState state = tester.state(find.byType(Dashboard));
      expect(state, isNotNull);
      expect(state.widget, equals(dashboard));
      final text = find.text('Campus Connected');

      final BuildContext context = tester.element(text);
      expect(context, isNotNull);

      await state.checkIsLoggedIn();
      expect(state.isLoggedIn, false);
      expect(state.firebaseUser, isNull);

      final appBar = state.appBar(context);
      TestHelper.checkWidget<AppBar>(appBar);

      final logo = state.appLogo(context);
      TestHelper.checkWidget<Container>(logo);

      //final profile = state.profileNameAndImage(context);
      //TestHelper.checkWidget<Padding>(profile);

      final entity = DashboardItem('test', 'test.png');
      expect(entity, isNotNull);
      final item = state.getListItem(false, entity, context);
      TestHelper.checkWidget<ListTile>(item);

      final item1 = state.getListItem(true, entity, context);
      TestHelper.checkWidget<Container>(item1);

      final login =
          state.drawerItem(context, 'Login', Icons.account_circle, 'login');
      TestHelper.checkWidget<ListTile>(login);
      checkListTitle(login, 'Login');

      final users = state.drawerItem(context, 'Users', Icons.person, 'users');
      TestHelper.checkWidget<ListTile>(users);
      checkListTitle(users, 'Users');

      final events =
          state.drawerItem(context, 'Events', Icons.event_available, 'events');
      TestHelper.checkWidget<ListTile>(events);
      checkListTitle(events, 'Events');

      final crEvents =
          state.drawerItem(context, 'Create Events', Icons.event, 'login');
      TestHelper.checkWidget<ListTile>(crEvents);
      checkListTitle(crEvents, 'Create Events');

      final logout =
          state.drawerItem(context, 'Log Out', Icons.exit_to_app, 'logout');
      TestHelper.checkWidget<ListTile>(logout);
      checkListTitle(logout, 'Log Out');

      final body = state.getBody(context);
      TestHelper.checkWidget<Container>(body);

      final rootDrawer = state.getDrawer(context);
      TestHelper.checkWidget<Drawer>(rootDrawer);

      final root = state.build(context);
      TestHelper.checkWidget<WillPopScope>(root);

      state.scaffoldKey.currentState.openDrawer();
      await tester.pump();

      final lItem = find.byType(ListTile).at(0);
      expect(lItem, isNotNull);
      await tester.tap(lItem);

      final lItem1 = find.byType(ListTile).at(1);
      expect(lItem1, isNotNull);
      await tester.tap(lItem1);

      final lItem2 = find.byType(ListTile).at(1);
      expect(lItem2, isNotNull);
      await tester.tap(lItem2);

      final tEvents = find.text('Events');
      expect(tEvents, findsWidgets);

      //widget
      final drawer = find.byTooltip('Open navigation menu');
      expect(drawer, findsWidgets);
      //tester.tap(drawer) ;
    });
  });

  testWidgets('BackButton control test', (WidgetTester tester) async {
    await tester.pumpWidget(
        MaterialApp(
          home: const Material(child: Text('Home')),
          routes: <String, WidgetBuilder>{
            '/next': (BuildContext context) {
              return const Material(
                child: Center(
                  child: BackButton(),
                ),
              );
            },
          },
        )
    );

    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/next');

    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));

    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('BackButton icon', (WidgetTester tester) async {
    final Key iOSKey = UniqueKey();
    final Key androidKey = UniqueKey();


    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: <Widget>[
            Theme(
              data: ThemeData(platform: TargetPlatform.iOS),
              child: BackButtonIcon(key: iOSKey),
            ),
            Theme(
              data: ThemeData(platform: TargetPlatform.android),
              child: BackButtonIcon(key: androidKey),
            ),
          ],
        ),
      ),
    );

    final Icon iOSIcon = tester.widget(find.descendant(of: find.byKey(iOSKey), matching: find.byType(Icon)));
    final Icon androidIcon = tester.widget(find.descendant(of: find.byKey(androidKey), matching: find.byType(Icon)));
    expect(iOSIcon == androidIcon, false);
  });

  testWidgets('BackButton semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: const Material(child: Text('Home')),
        routes: <String, WidgetBuilder>{
          '/next': (BuildContext context) {
            return const Material(
              child: Center(
                child: BackButton(),
              ),
            );
          },
        },
      ),
    );

    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/next');

    await tester.pumpAndSettle();

    expect(tester.getSemantics(find.byType(BackButton)), matchesSemantics(
      label: 'Back',
      isButton: true,
      hasEnabledState: true,
      isEnabled: true,
      hasTapAction: true,
    ));
    handle.dispose();
  });
}
