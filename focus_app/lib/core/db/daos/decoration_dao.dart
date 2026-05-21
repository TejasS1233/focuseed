import 'package:drift/drift.dart';
import '../database.dart';

part 'decoration_dao.g.dart';

@DriftAccessor(tables: [Decorations])
class DecorationDao extends DatabaseAccessor<AppDatabase> with _$DecorationDaoMixin {
  DecorationDao(AppDatabase db) : super(db);

  Future<List<Decoration>> getByUser(String userId) {
    return (select(decorations)..where((d) => d.userId.equals(userId))).get();
  }

  Future<void> place(Decoration decoration) => into(decorations).insert(decoration);

  Future<void> remove(String id) =>
      (delete(decorations)..where((d) => d.id.equals(id))).go();

  Future<Decoration> randomForSession(String userId) async {
    final types = ['stone', 'flower', 'grass', 'mushroom'];
    final type = types[(DateTime.now().millisecondsSinceEpoch ~/ 1000) % types.length];
    return Decoration(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      type: type,
      x: 0.1 + (DateTime.now().millisecondsSinceEpoch % 80) / 100,
      y: 0.1 + ((DateTime.now().millisecondsSinceEpoch ~/ 100) % 80) / 100,
      placedAt: DateTime.now(),
    );
  }
}
