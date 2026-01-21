import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uts_backend/model/cari_sparring_model.dart';

class DatabaseSqf {
  String db_name = "gor_kita";
  int version_db = 3;
  Database? db;

  getDatabase() async {
    if (db != null) {
      return db;
    }
    db = await initDatabase();
    return db;
  }

  initDatabase() async {
    String dbpath = await getDatabasesPath();
    String path = join(dbpath, db_name);
    return await openDatabase(
      path,
      version: version_db,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE cari_sparring (id INTEGER PRIMARY KEY AUTOINCREMENT,uidspar TEXT NOT NULL,uiduser1 TEXT NOT NULL,uiduser2 TEXT,nama_sparring TEXT NOT NULL,venue TEXT NOT NULL,tanggal TEXT NOT NULL,kategori TEXT NOT NULL)',
        );
      },
    );
  }

  getSparringByIdUser(String uid) async {
    Database ddata = await getDatabase();
    List<Map<String, dynamic>> data = await ddata.query(
      'cari_sparring',
      where: 'uiduser1 = ?',
      whereArgs: [uid],
    );
    List<CariSparringModel> hasil = data.map((e) {
      return CariSparringModel.fromJson(e);
    }).toList();
    return hasil;
  }

  deleteSparringByUid(String uidspar) async {
    Database ddata = await getDatabase();
    await ddata.delete(
      'cari_sparring',
      where: 'uidspar = ?',
      whereArgs: [uidspar],
    );
  }

  insertCariSparring(CariSparringModel data) async {
    Database ddata = await getDatabase();
    int test = await ddata.insert('cari_sparring', data.toJson());
    return test;
  }
}
