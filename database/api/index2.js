const express = require('express')
const app = express()
const mysql = require('mysql2')
const cors = require('cors')
const { exec } = require('child_process');
const { error } = require('console');
const { stat } = require('fs');
const e = require('express');
app.use(express.json())
app.use(express.urlencoded({extended: false}))


const db = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "",
    database: "gor_terbaru"
   
})

app.use(cors())


app.put('/gambar/profil/:id', (req, res) => {
    const userId = req.params.id;
    const { url } = req.body;

    // Validasi input
    if (!url || url.trim() === '') {
        return res.status(400).send({
            status: 400,
            message: "URL gambar tidak boleh kosong"
        });
    }

    // Gunakan parameterized query
    const sql = `UPDATE user SET photo_url = ? WHERE user_id = ?`;
    
    db.query(sql, [url, userId], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).send({
                status: 500,
                message: "Gagal mengganti foto profil"
            });
        }

        if (results.affectedRows === 0) {
            return res.status(404).send({
                status: 404,
                message: "User tidak ditemukan"
            });
        }

        res.send({
            status: 200,
            message: "Berhasil mengganti foto profil",
            data: {
                user_id: userId,
                photo_url: url
            }
        });
    });
});
app.post('/validate/login/user', (req, res) => {
    let isi = req.body;
    console.log(`ini ${isi.email}`)
    // ✅ Validasi data terlebih dahulu
    if (!isi || !isi.email || !isi.password) {
        return res.status(400).send({
            status: "Data tidak lengkap",
            allow: false
        });
    }
    
    let sql = `SELECT user.user_id FROM user where user.email = "${isi.email}" AND user.password = "${isi.password}"`;
    db.query(sql, (err, results) => {
        if (err) {
            console.log(`Error login: ${err}`);
            return res.status(500).send({
                status: "Server error",
                allow: false
            });
        }
        
        if (results.length == 0) {
            res.send({
                status: "Email/Password Salah",
                allow: false
            });
        } else {
            res.send({
                status: "Berhasil Login",
                allow: true,
                id_user: results[0]["user_id"]
            });
        }
    });
});

app.post('/check/user/daftar', (req, res) => {
    let isi = req.body;
    
    // ✅ Validasi data
    if (!isi || !isi.email) {
        return res.status(400).send({
            status: "Email tidak provided",
            allow: false
        });
    }
    
    let sql = `SELECT user.email FROM user WHERE user.email = "${isi.email}"`;
    db.query(sql, (err, results) => {
        if (err) {
            console.log(`Error check email: ${err}`);
            return res.status(500).send({
                status: "Server error",
                allow: false
            });
        }
        
        if (results.length == 0) {
            res.send({
                status: "Email belum terdaftar",
                allow: true
            });
        } else {
            res.send({
                status: "Email sudah terdaftar",
                allow: false
            });
        }
    });
});
app.post('/add/user',(req,res) =>{
    let isi = req.body
    let sql = `INSERT INTO user (name, email, password, phone, level_skill)  VALUES('${isi.name}', '${isi.email}', '${isi.password}','${isi.phone}','${isi.level_skill}')`
    db.query(sql,(err,results) =>{
        if(err){
            console.log(`Error add user : ${err}`)
            res.status(500).send({
                message: err
            })
        }
        res.send(
            {
                status:200,
                message: "Berhasil Menambahkan User!"
            }
        )
    })
})


app.put('/user/edit/password/:id',(req,res)=>{
    let isi = req.body
    
    let sql = `UPDATE user SET password = "${isi.password}" WHERE user_id = ${req.params.id}`
    
    db.query(sql,(err,results) =>{
        if(err){
            console.log(`Error update password : ${err}`)
            return res.status(500).send({
                success: false,
                message: "Gagal update password"
            })
        }
        
        res.send({
            success: true,
            message: "Password berhasil diubah",
            status: 200,
            data: results
        })
    })
})

app.post('/send-reset-code', (req, res) => {
    let isi = req.body;
    
    if (!isi.email) {
        return res.status(400).send({
            success: false,
            message: "Email harus diisi"
        });
    }

    let sqlCheck = `SELECT user_id, email FROM user WHERE email = "${isi.email}"`;
    db.query(sqlCheck, (err, results) => {
        if (err) {
            console.log(`Error check email: ${err}`);
            return res.status(500).send({
                success: false,
                message: "Server error"
            });
        }
        
        if (results.length === 0) {
            return res.send({
                success: false,
                message: "Email tidak terdaftar"
            });
        }

        res.send({
            success: true,
            message: "Kode reset telah dikirim ke email Anda",
            debug_code: "123456" 
        });
    });
});

app.post('/reset-password-with-code', (req, res) => {
    let isi = req.body;
    
    if (!isi.email || !isi.code || !isi.new_password) {
        return res.status(400).send({
            success: false,
            message: "Data tidak lengkap"
        });
    }

    let sql = `UPDATE user SET password = "${isi.new_password}" WHERE email = "${isi.email}"`;
    
    db.query(sql, (err, results) => {
        if (err) {
            console.log(`Error reset password: ${err}`);
            return res.status(500).send({
                success: false,
                message: "Gagal reset password"
            });
        }
        
        if (results.affectedRows === 0) {
            return res.send({
                success: false,
                message: "Email tidak ditemukan"
            });
        }

        res.send({
            success: true,
            message: "Password berhasil direset"
        });
    });
});


app.post('/verify-reset-code', (req, res) => {
    let isi = req.body;
    
    if (!isi.email || !isi.code) {
        return res.status(400).send({
            success: false,
            message: "Email dan kode harus diisi"
        });
    }

    res.send({
        success: true,
        message: "Kode valid"
    });
});

app.get('/user/:id',(req,res) =>{
    let id = req.params.id
    let sql = `SELECT * from user u where u.user_id = ${id}`
    db.query(sql,(err,results) =>{
        if(err){
            console.log(`Error jadwal : ${err}`)
            res.status(500).send({
                message: err
            })
        }
        res.send(
            {
                status:200,
                data : results
            }
        )
    })
})

app.get('/detail/venue/:id',(req,res)=>{
    let id = req.params.id
    let sql = `SELECT 
    v.*, 
    GROUP_CONCAT(DISTINCT f.nama_fasilitas ORDER BY vf.fasilitas_id SEPARATOR ', ') AS list_fasilitas,
    GROUP_CONCAT(DISTINCT f.fasilitas_id ORDER BY vf.fasilitas_id SEPARATOR ',') AS id_fasilitas,
    GROUP_CONCAT(DISTINCT lk.url_gambar ORDER BY lk.gambar_id SEPARATOR ', ') AS url_gambar
    FROM venue v
    LEFT JOIN venue_facility vf ON vf.venue_id = v.venue_id
    LEFT JOIN facility f ON f.fasilitas_id = vf.fasilitas_id
    LEFT JOIN link_gambar lk ON lk.venue_id = v.venue_id
    WHERE v.venue_id = ${id}
    GROUP BY v.venue_id;`
    db.query(sql,((err,results)=>{
        if(err){
            console.log(`Error v3enue : ${err}`)
            res.status(500).send({
                message: err
            })
        }
        res.send(
            {
                status:200,
                data : {
                    "venue_id" : results[0]["venue_id"],
                    "nama_venue" : results[0]["nama_venue"],
                    "alamat" : results[0]["alamat"],
                    "deskripsi" : results[0]["deskripsi"],
                    "kota" : results[0]["kota"],
                    "harga_perjam" : results[0]["harga_perjam"],
                    "total_rating"  : results[0]["total_rating"],
                    "jam_operasional" : results[0]["jam_operasional"],
                    "rating" : results[0]["rating"],
                    "status" : results[0]["status"],
                   
                    "fasilitas" : results[0]["id_fasilitas"].split(",").map((id, i) => ({
                            
                            id: id.trim(),
                            nama: results[0]["list_fasilitas"].split(",")[i].trim()
                        })),
                    link_gambar : results[0]["url_gambar"].split(', ')
                },
            }
        )
    }))
})

app.get('/sparring/history',(req,res)=>{
    let sql = `SELECT s.sparring_id,s.tanggal,s.maximum_available_time,s.kota,s.provinsi,GROUP_CONCAT(
        CASE 
            WHEN sp.isOpponent = 0 THEN u.name 
            ELSE NULL 
        END 
        ORDER BY sp.user_id SEPARATOR ', '
    ) AS player_a,
    GROUP_CONCAT(
        DISTINCT CASE 
            WHEN sp.isOpponent = 1 THEN u.name 
            ELSE NULL 
        END 
        ORDER BY sp.user_id SEPARATOR ', '
    ) AS player_b,s.kategori,
    CONCAT(sh.skor_set1, ',', sh.skor_set1b) AS skor_set1,
    CONCAT(sh.skor_set2, ',', sh.skor_set2b) AS skor_set2,
    CONCAT(sh.skor_set3, ',', sh.skor_set3b) AS skor_set3
    FROM sparring s
    LEFT JOIN sparring_participant sp ON sp.sparring_id = s.sparring_id
    LEFT JOIN user u ON u.user_id = sp.user_Id
    LEFT JOIN sparring_history sh ON sh.sparring_id = s.sparring_id
    GROUP BY s.sparring_id
    HAVING SUM(sp.isOpponent)>=1;`
    db.query(sql,(err,results)=>{
        if(err){
            console.log(`Error sparring : ${err}`)
            res.status(500).send({
                message: err
            })
        }
        res.send(
            {
                status:200,
                data : results
            }
        )
    })
})

app.get('/display/sparring',(req,res)=>{
    let sql = `SELECT 
    s.sparring_id,
    v.nama_venue,
    s.nama_tim,
    s.kota,
    s.kategori,
    s.provinsi,
    s.minimum_available_time,
    s.maximum_available_time,
    s.tanggal,
    GROUP_CONCAT(
        CASE 
            WHEN sp.isOpponent = 0 THEN u.name 
            ELSE NULL 
        END 
        ORDER BY sp.user_id SEPARATOR ', '
    ) AS search_player
    FROM sparring s
    LEFT JOIN venue v ON s.venue_id = v.venue_id
    LEFT JOIN sparring_participant sp ON sp.sparring_id = s.sparring_id
    LEFT JOIN user u ON u.user_id = sp.user_id
    GROUP BY s.sparring_id
    HAVING SUM(sp.isOpponent) =0;`
    db.query(sql,((err,results)=>{
        if(err){
            console.log(`Error sparring : ${err}`)
            res.status(500).send({
                message: err
            })
        }
        res.send(
            {
                status:200,
                data : results
            }
        )
    }))
})

app.get('/display/mabar',(req,res) =>{
    let sql = `SELECT 
    m.mabar_id,
    m.judul,
    m.level_minimum,
    m.level_maksimum,
    m.tanggal,
    m.jam_mulai,
    m.jam_selesai,
    m.capacity,
    v.nama_venue,
    v.kota,
    
    (
        SELECT u2.name 
        FROM user u2
        JOIN mabar_participant mp2 ON mp2.user_id = u2.user_id
        WHERE mp2.mabar_id = m.mabar_id AND mp2.status = 'host'
        LIMIT 1
    ) AS host,
    
    GROUP_CONCAT(
        CASE WHEN mp.status = 'member' THEN u.name END
        ORDER BY u.user_id SEPARATOR ', '
    ) AS register

    FROM mabar m
    LEFT JOIN mabar_participant mp 
        ON mp.mabar_id = m.mabar_id
    LEFT JOIN venue v
        ON v.venue_id = m.venue_id
    LEFT JOIN user u 
        ON u.user_id = mp.user_id
    GROUP BY m.mabar_id, m.judul;`
    db.query(sql,((err,results) =>{
        if(err){
            console.log(`Error mabar : ${err}`)
            res.status(500).send({
                message: err
            })
        }
        res.send(
            {
                status:200,
                data : results
            }
        )
    }))
})

app.get('/getall/user',(req,res) =>{
    let sql = `SELECT u.user_id,u.name FROM user u`
    db.query(sql,((err,results)=>{
        if(err){
            console.log(`Error get alluser : ${err}`)
            res.status(500).send({
                message: err
            })
        }
        res.send(
            {  
                status:200,
                data : results
                   
            }
        )
    }))
})



app.get('/display/venue',(req,res) =>{
    let sql = `SELECT v.venue_id,v.nama_venue,v.kota,v.rating,v.total_rating,v.harga_perjam,GROUP_CONCAT(lk.url_gambar ORDER BY lk.gambar_id SEPARATOR ', ' LIMIT 1) AS url FROM venue v 
    LEFT JOIN link_gambar lk  ON lk.venue_id = v.venue_id
    GROUP BY v.venue_id;`
    db.query(sql,((err,results) =>{
        if(err){
            console.log(`Error venue : ${err}`)
            res.status(500).send({
                message: err
            })
        }
        res.send(
            {  
                status:200,
                data : results
                   
            }
        )
    }))
})

app.get('/all/jadwal',(req,res)=>{
    let sql = `SELECT jadwal.*, venue.nama_venue FROM jadwal INNER JOIN venue ON jadwal.venue_id = venue.venue_id;
`
    db.query(sql, ((err,results) =>{
        if(err){
            console.log(`Error venue : ${err}`)
            res.status(500).send({
                message: err
            })
        }
        res.send(
            {
                status:200,
                data : results
            }
        )
    }))

})

app.delete('/notif/delete/:id',(req,res)=>{
    let sql = `DELETE from notifikasi WHERE notifikasi.notif_id = ${req.params.id}`
    db.query(sql,(err,results)=>{
        if(err){
            res.status(500).send({
                status:500,
                message: err
            })
        }
        res.send({
            status:200,
            message:"Succes delete notif"
        })
    })
})

app.get('/notif',(req,res)=>{
    let sql = `SELECT * from notifikasi`
    db.query(sql,(err,results) =>{
        if(err){
            res.status(500).send({
                status:500,
                message: err
            })
        }
        res.send({
            status:200,
            data:results
        })
    })
})

app.post('/add/sparring', (req, res) => {
    let isi = req.body;

    let sql = `
        INSERT INTO sparring 
        (venue_id,tanggal,minimum_available_time,maximum_available_time,provinsi,kota,kategori,nama_tim) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;

    db.query(sql, [
        isi.venue_id, isi.tanggal, isi.minimum_available_time, isi.maximum_available_time,
        isi.provinsi, isi.kota, isi.kategori, isi.nama_tim
    ], (err, results) => {

        if (err) {
            console.error(`Err : ${err}`)
            return res.status(500).json({ message: err })
        }

        let sparringID = results.insertId;
        let inserts = [];

        if (isi.user) inserts.push([isi.user, sparringID, 0]);
        if (isi.user2) inserts.push([isi.user2, sparringID, 0]);

        if (inserts.length === 0) {
            return res.json({
                message: "Sparring berhasil dibuat TANPA participant",
                sparring_id: sparringID
            });
        }

        let sql2 = `INSERT INTO sparring_participant (user_Id, sparring_id, isOpponent) VALUES ?`;

        db.query(sql2, [inserts], (err2) => {
            if (err2) {
                console.error(err2);
                return res.status(500).json({ message: err2 });
            }

            return res.json({
                message: "Berhasil menambahkan sparring + participants",
                sparring_id: sparringID
            });
        });
    });
});


 

app.post('/add/venue',(req,res)=>{
    let isi = req.body
    
    let sql = `
    INSERT INTO venue (nama_venue,alamat,deskripsi,kota,harga_perjam,rating,status,total_rating,jam_operasional) VALUES ('${isi["nama_venue"]}', '${isi["alamat"]}', '${isi["deskripsi"]}', '${isi["kota"]}', ${isi["harga_perjam"]}, ${isi["rating"]}, ${isi["status"]}, ${isi["total_rating"]}, '${isi["jam_operasional"]}')`

    db.query(sql, ((err,results)=>{
        if(err){
            console.error(`Err : ${err}`)
            res.status(500).json({
                message: err
            })
        }
        
    }))

})

app.get('/display/venue/booking/:id', (req, res) => {
    const venue_id = req.params.id;
    
    let { dateTimeStart, dateTimeEnd } = req.query;
 
    if (!dateTimeStart || !dateTimeEnd) {
        return res.status(400).send({
            message: "dateTimeStart and dateTimeEnd are required as query parameters"
        });
    }
 
    dateTimeStart = dateTimeStart.substring(0, 19);
    dateTimeEnd = dateTimeEnd.substring(0, 19);
 
    const mysqlStart = dateTimeStart.replace("T", " ");
    const mysqlEnd = dateTimeEnd.replace("T", " ");
 
    const sql = `SELECT
            jb.id,
            jb.lapangan,
            DATE_FORMAT(jb.dateTime, '%Y-%m-%d %H:%i:%s') AS dateTime
        FROM jadwal_booking jb
        JOIN venue v ON jb.venue_id = v.venue_id
        WHERE jb.venue_id = ?
        AND jb.dateTime BETWEEN ? AND ?
        ORDER BY jb.lapangan, jb.dateTime ASC`
    ;
 
    db.query(sql, [venue_id, mysqlStart, mysqlEnd], (err, results) => {
        if (err) {
            console.error("Error booking:", err);
            return res.status(500).send({ message: err });
        }
 
        if (results.length === 0) {
            return res.send({
                status: 200,
                data: {}
            });
        }
 
        const grouped = {};
 
        results.forEach(row => {
            if (!grouped[row.lapangan]) {
                grouped[row.lapangan] = {
                    nama: row.lapangan,
                    id: row.id,
                    jadwal: []
                };
            }
 
            grouped[row.lapangan].jadwal.push(
                row.dateTime
            );
        });
 
        return res.send({
            status: 200,
            data: {
                lapangan: Object.values(grouped),
            }
        });
    });
});


app.get('/api/test', (req, res) => {
    console.log('✅ Ngrok test endpoint accessed');
    res.json({
        success: true,
        message: 'Backend connected via ngrok successfully!',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to Backend API',
        status: 'running',
        via_ngrok: true
    });
});


app.listen(3000, () => {
    console.log(`Example appp listening on port localhost:3000`)
})