const express=require('express')
const app=express();

const api=require('./client/api');
const authentication=require('./client/authentication');
const cart=require('./client/cart');
const payment=require('./client/payment');
const product=require('./client/product');

app.use('/api',api);
app.use('/authentication',authentication);
app.use('/cart',cart);
app.use('/product',product);
app.use('/payment',payment);

module.exports=app;