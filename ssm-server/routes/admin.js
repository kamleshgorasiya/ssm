const express=require('express')
const app=express();

const product=require('./admin/products');
const attribute=require('./admin/attributes');
const attributeValue=require('./admin/attributeValueApi');
const category=require('./admin/category');
const order=require('./admin/orders');
const authentication=require('./admin/authentication');

app.use('/authentication',authentication);
app.use('/product',product);
app.use('/attribute',attribute);
app.use('/attributeValue',attributeValue);
app.use('/category',category);
app.use('/order',order);

module.exports=app;