const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
  street: String,
  number: String,
  city: String,
  state: String,
  zip: String,
  complement: String,
  neighborhood: String,
});

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
    addresses: [addressSchema],
    defaultAddressId: {  
        type: mongoose.Schema.Types.ObjectId,
        required: false,
        ref: 'User.addresses',  // Ref aos endereços
    },
});

module.exports = mongoose.model('User', UserSchema);