import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:focus_app/core/db/database.dart';
import 'package:focus_app/core/db/daos/blacklist_dao.dart';

void main() {
  late AppDatabase db;
  late BlacklistDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = BlacklistDao(db);
  });

  tearDown(() => db.close());

  test('add and retrieve blacklisted package', () async {
    await dao.add('com.example.app');
    final all = await dao.getAllPackageNames();
    expect(all, contains('com.example.app'));
  });

  test('duplicate package is not inserted', () async {
    await dao.add('com.example.app');
    await dao.add('com.example.app');
    final all = await dao.getAllPackageNames();
    expect(all.length, 1);
  });

  test('remove package from blacklist', () async {
    await dao.add('com.example.app');
    await dao.remove('com.example.app');
    final all = await dao.getAllPackageNames();
    expect(all, isEmpty);
  });

  test('isBlacklisted returns correct status', () async {
    expect(await dao.isBlacklisted('com.example.app'), false);
    await dao.add('com.example.app');
    expect(await dao.isBlacklisted('com.example.app'), true);
  });
}
