const express=require('express')
const jwt=require('jsonwebtoken')
const bcrypt=require('bcrypt');
const router=express.Router();
const limit=10;

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

router.get('/getAllCategory/:up',verifyToken,(req,res)=>{
    let up=req.params.up;
    let sql="select c.*,d.name as dname from category c,department d where c.department_id=d.department_id and c.isDelete=0 limit "+up+","+limit;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(result){
                res.status(200).json(result);
            } else {
                res.status(404).send("There is no product");
            }
        }
    });
});

router.get('/getDepartments',verifyToken,(req,res)=>{
    let sql="select * from department";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(result){
                res.status(200).json(result);
            } else {
                res.status(404).send("No data is found");
            }
        }
    });
});

router.get('/countCategory',verifyToken,(req,res)=>{
    let sql="select count(*) as countCategory from category where isDelete=0";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    });
});

router.post('/addCategory',verifyToken,(req,res)=>{
   let category=req.body;
   if(category.name.length<2){
       res.status(500).send("Data is not Proper. Enter name of more than 2 Characters");
   } else{
       if(typeof category.department_id!='number'){
           res.status(500).send("Select the department properly");
       } else {
           let sql='insert into category(department_id,name,description) values ('+category.department_id+',"'+category.name+'","'+category.description+'")';
           con.query(sql,(err,result)=>{
               if(err){
                   console.log(err);
               } else {
                   res.status(200).send({message:"Category added successfully"});
               }
           })
       }
   }
});

router.post('/updateCategory',verifyToken,(req,res)=>{
    let category=req.body;
    if(category.name.length<2){
        res.status(500).send("Data is not Proper. Enter name of more than 2 Characters");
    } else{
        if(typeof category.department_id!='number'){
            res.status(500).send("Select the department properly");
        } else {
            let sql='update category set department_id='+category.department_id+', name="'+category.name+'", description="'+category.description+'" where category_id='+category.category_id;
            con.query(sql,(err,result)=>{
                if(err){
                    console.log(err);
                } else {
                    res.status(200).send({message:"Category updated successfully"});
                }
            })
        }
    }
});

router.post('/activateCategory',verifyToken,(req,res)=>{
    let category=req.body;
    let sql = "update category set active="+category.active+" where category_id="+category.category_id;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.status(200).send({"message":"Category is updated Suucessfully"});
        }
    });
});

router.post('/deleteCategory',verifyToken,(req,res)=>{
    let category=req.body;
    let sql="  count(o.item_id) as totalorder from order_detail o,product_variants pv,product_category pc where pc.category_id="+ category.category_id+" and pc.product_id=pv.product_id and pv.variant_id=o.product_variant_id";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(result[0].totalorder<1){
                sql="update category set isDelete=1  where category_id="+category.category_id;
                con.query(sql,(err,result)=>{
                    if(err){
                        console.log(err);
                    } else {
                        res.status(200).send({"message":"Category is deleted successfully"});
                    }
                })
            } else {
                res.status(200).send({"message":"Category is aleready in use"});
            }
        }
    });
});

router.get('/getProductWithNoSQL',(req,res)=>{
    let sql="select * from product";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    });
});

router.post('/changeAllCategoryStatus',verifyToken,(req,res)=>{
    let data=req.body;
    let categories=data.category;
    if(categories.length>0){
        let sql="update category set active="+data.status+" where category_id in(";
        for(let i=0;i<categories.length;i++){
            if(i==0){
                sql=sql+categories[i].category_id;
            } else {
                sql=sql+","+categories[i].category_id;
            }
        }
        sql=sql+")";
        
        con.query(sql,(err,result)=>{
            if(err){
                console.log(err);
            } else {
                res.json({"message":"Change status of categories successfully"});
            }
        });
    } else {
        res.status(500).send({"message":"Inproper data found"});
    }
});

router.get('/searchCategory/:key/:up',verifyToken,(req,res)=>{
    let key=req.params.key;
    let up=req.params.up;
    if(key!=""){
        let sql='select c.*,d.name as dname from category c,department d where c.department_id=d.department_id and c.isDelete=0 and c.name like "%'+ key +'%" limit '+up+','+limit;
        con.query(sql,(err,result)=>{
            if(err){
                console.log(err);
            } else {
                let response=new Array();
                response.push(result);
                sql='select count(*) as countCategory from category where isDelete=0 and name like "%'+ key +'%"';
                con.query(sql,(err,count)=>{
                    if(err){
                        console.log(err);
                    } else {
                        response.push(count);
                        res.status(200).json(response);
                    }
                });
            }
        });
    }
});

router.get('/categoryByDepartment/:department_id/:up',verifyToken,(req,res)=>{
    let department_id=req.params.department_id;
    let up=req.params.up;
    let sql="select c.*,d.name as dname from category c,department d where c.department_id=d.department_id and c.department_id="+department_id+" and c.isDelete=0 limit "+up+" , "+limit;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            let response=new Array();
            response.push(result);
            sql="select count(*) as countCategory from category where department_id="+department_id;
            con.query(sql,(err,count)=>{
                if(err){
                    console.log(err);
                } else {
                    response.push(count);
                    res.status(200).json(response);
                }
            })
        }
    })
});

router.get('/getCategoriesByDepartment/:department_id',verifyToken,(req,res)=>{
    let department_id=req.params.department_id;
    let sql="select * from category where department_id="+department_id;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    });
});


router.get('/getProductWithSQL',(req,res)=>{
    let sql="select p.*,av.value,a.name from product p,attribute_value av,attribute a,product_attribute pa where pa.product_id=p.product_id and pa.attribute_value_id=av.attribute_value_id and av.attribute_id=a.attribute_id";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
            // let response=new Array();
            // let data={};
            // for(let i=0;i<result.length;i++){
            //     if(i==0){
            //         data.product_id=result[i].product_id;
            //         data.description=res
            //     } else {
            //         if(result[i].product_id!=result[i-1].product_id){
            //             data.product_id=result[i].product_id;
            //         }
            //     }

            // }
        }
    })
});

router.get('/productWiseAttributes',(req,res)=>{
    let sql="select * from product limit 0,25";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err); 
        } else {
            let response=new Array();
            let attributes=new Array();
            response.push(result);
            let i=0;
                // while(i<result.length){
                // var p=new Promise(function(resolve,reject){
                //     sql="select pa.*,av.value,av.attribute_id,a.name from product_attribute pa,attribute_value av,attribute a where pa.product_id="+result[i].product_id+" and pa.attribute_value_id=av.attribute_value_id and av.attribute_id=a.attribute_id";
                //     console.log(sql);
                //     con.query(sql,(err,attribute)=>{
                //         if(err){
                //             console.log(err);
                //         } else {
                //             console.log("sql");
                //             resolve(attribute);
                //         }
                //     })
                // });
                // p.then(function(value){
                //     attributes.push(attribute);
                //         i++;
                // })
                
                sql="select pa.*,av.value,av.attribute_id,a.name from product_attribute pa,attribute_value av,attribute a where pa.product_id="+result[i].product_id+" and pa.attribute_value_id=av.attribute_value_id and av.attribute_id=a.attribute_id";
                console.log(sql);
                con.query(sql,(err,attribute)=>{
                    if(err){
                        console.log(err);
                    } else {
                        console.log("sql");
                        attributes.push(attribute);
                        i++;
                    }
                })
                if(i==result.length-1){
                    response.push(attributes);
                    res.json(response);
                } else {
                    
                }
            }
        //}
    })
})
module.exports=router;