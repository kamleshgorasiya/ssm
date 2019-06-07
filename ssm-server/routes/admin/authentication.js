const express=require('express')
const jwt=require('jsonwebtoken')
const bcrypt=require('bcrypt');
const router=express.Router();

const con=require('../../database_connection');

function verifyToken(req,res,next){
    if(!req.headers.authorization){
        return res.status(401).send("Unauthorized Request! Header Not Found");
    }
    let token=req.headers.authorization.split(' ')[1];
    if(token==="null"){
        return res.status(401).send("Unauthorized Request! Token Not Found");
    }
    let payload=jwt.verify(token,'MysupersecreteKey');
   
    if(!payload){
        return res.status(401).send("Unauthorized Request! Token is not Correct");
    }
    req.userId=payload.subject;
    next(); 
}

router.post('/loginUser',(req,res)=>{
    let user=req.body;
    let sql="select * from user where email='"+user.email+"'";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(!result){
                res.status(401).send("Invalid email");
            } else {
              
                if(result.length<1){
                    res.status(500).send("Invalid Password!!");
                } else {
                    var passwordChecker=new Promise((resolve,reject)=>{
                        bcrypt.compare(user.password,result[0].password,(err,response)=>{
                            resolve(response);
                        })
                    })
                    passwordChecker.then(function(val){
                        if(val){
                            let payload ={subject:result[0].user_id};
                            let token = jwt.sign(payload,'MysupersecreteKey');
                            res.status(200).send({token});
                        } else{
                            res.status(500).send("Invalid Password!!");
                        }
                    });
                }
            }
        }
    });
});

module.exports=router;