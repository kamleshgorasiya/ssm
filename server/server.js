const express=require('express');
const bodyParser=require('body-parser')
const cors=require('cors');
const port=3000;
const api=require('./routes/api')
const auth=require('./routes/authentication');
const product=require('./routes/product');
const cart=require('./routes/cart');
const payment=require('./routes/payment');
const app=express()
app.use(cors())
app.use(bodyParser.json())
app.use('/api',api)
app.use('/authentication',auth)
app.use('/cart',cart);
app.use('/product',product);
app.use('/payment',payment);
app.get('/',function(req,res){
    res.send("Hello from Server");
});

app.listen(port,function(){
    console.log("Server running on "+port);
})