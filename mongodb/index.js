const dotenv = require("dotenv");
dotenv.config();
const mongoose = require('mongoose');
const settings = require('../controllers/settings')

const url = `mongodb://${process.env.MONGO_URL}:27017/todoDB`

function connectMongoDb() {
    mongoose.connect(url || settings.dbURI, { 
      useNewUrlParser: true, 
      useUnifiedTopology: true
    });
    const db = mongoose.connection;
    db.on('error', console.error.bind(console, 'connection error:'));
    db.once('open', () => {
      console.log('[INFO] Connect to DB success!');
    });
}

module.exports.connectMongoDb = connectMongoDb