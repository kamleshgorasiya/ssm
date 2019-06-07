const express=require('express');
const bodyParser=require('body-parser')
const path=require('path')
const cors=require('cors');
const port=3000;
const client=require('./routes/client');
const admin=require('./routes/admin');


const app=express()

app.use(cors())
app.use(bodyParser.json())

app.use('/admin',admin);
app.use('/client',client);

app.get('/',function(req,res){
    res.send("Hello from Server");
});

app.listen(port,function(){
    console.log("Server running on "+port);
})

module.exports=app;