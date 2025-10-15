const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true,
    },
    password: {
        type: String,
        required: true,
    },
    phone: {
        type: String,
        required: false,
        unique: false,
        trim: true,
    },
    name: {
        type: String,
        required: false,
        trim: true,
    },
    cpf: {
        type: String,
        required: false,
        unique: false,
        trim: true,
    },
});

module.exports = mongoose.model('User', UserSchema);