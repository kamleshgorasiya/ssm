const express=require('express');
const multer=require('multer');
const sharp=require('sharp');
const fs=require('fs');
const path=require('path');
const jwt=require('jsonwebtoken');
const router=express.Router();
const limit=10;
// var upload=multer({dest:'../../Images/product_images'});
var app=express();
const con=require('../../database_connection');
app.use(express.static('../../Images/product_images'));


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

app.use((req,res,next)=>{
    res.header("Access-Control-Allow-Origin","*");
    res.header("Access-Control-Allow-Headers","Origin,X-Requested-With,Content-Type,Accept");
    next();
});

var storage=multer.diskStorage({
    destination:function(req,file,cb){
        
        cb(null,"/gaurang/Parth's workspace/ssm/Admin/src/assets/Images/main_image");
    },
    filename:function(req,file,cb){
        
        var ext=path.extname(file.originalname);
        var filename=file.originalname+"-"+Date.now()+ext;
        let sql="select large_image from product_variants where variant_id="+req.params.variant_id;
        con.query(sql,(err,result)=>{
            if(err) {
                console.log(err);
            } else {
                let check=0;
                let images=new Array();
                images=JSON.parse(result[0].large_image);

                try{
                    if(req.params.image_name){
                        for(let i=0;i<images.length;i++){
                            if(images[i]===req.params.image_name){
                                images[i]=filename.toString();
                                let filepath="/gaurang/Parth's workspace/ssm/Admin/src/assets/Images/main_image/"+images[i];
                                check=1;
                                break;
                            }
                        }
                        fs.unlinkSync(filepath);
                    }
                }
                 catch {
                    
                }
                if(check==0){
                    images.push(filename.toString());
                }
                
                sql="update product_variants set large_image='"+JSON.stringify(images)+"' where variant_id="+req.params.variant_id;
                con.query(sql,(err,result)=>{
                    if(err) {
                        console.log(err);
                    }
                });
            }
        });
        cb(null,filename);
    }
});

var upload=multer({storage:storage});

router.post('/upload-image/:variant_id',verifyToken,upload.array("uploads[]",12),(req,res)=>{
    let variant;
    let sql="select * from product_variants where variant_id="+req.params.variant_id;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            variant=result[0];
        }
    })
    sharp(req.files[0].path).resize(100).toFile("/gaurang/Parth's workspace/ssm/Admin/src/assets/Images/thumbnail/"+req.files[0].filename,(err,info)=>{
        if(err){
            console.log(err);
        } else {
            let images=JSON.parse(variant.thumbnail);
            images.push(req.files[0].filename);
            variant.thumbnail=JSON.stringify(images);
            sharp(req.files[0].path).resize(300).toFile("/gaurang/Parth's workspace/ssm/Admin/src/assets/Images/list_image/"+req.files[0].filename,(err,info)=>{
                if(err){
                    console.log(err);
                } else {
                    let images=JSON.parse(variant.list_image);
                    images.push(req.files[0].filename);
                    variant.list_image=JSON.stringify(images);
                    // console.log(variant)
                    sharp(req.files[0].path).resize(500).toFile("/gaurang/Parth's workspace/ssm/Admin/src/assets/Images/view_image/"+req.files[0].filename,(err,info)=>{
                        if(err){
                            console.log(err);
                        } else {
                            let images=JSON.parse(variant.view_image);
                            images.push(req.files[0].filename);
                            variant.view_image=JSON.stringify(images);
                
                            sql="update product_variants set thumbnail='"+variant.thumbnail+"', list_image='"+variant.list_image+"',view_image='"+variant.view_image+"' where variant_id="+variant.variant_id;
                            con.query(sql,(err,result)=>{
                                if(err) {
                                    console.log(err);
                                } else {
                                    res.send(req.files);
                                }
                            });
                        }
                    });
                }
            });
        }
    });
    
    // console.log(req.files[0].path)
    
});

router.post('/editImageUpload/:variant_id/:image_name',verifyToken,upload.array("uploads[]",12),(req,res)=>{
    let variant;
    let sql="select * from product_variants where variant_id="+req.params.variant_id;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            variant=result[0];
        }
    })
    
    sharp(req.files[0].path).resize(100).toFile("/gaurang/Parth's workspace/ssm/Admin/src/assets/Images/thumbnail/"+req.files[0].filename,(err,info)=>{
        if(err){
            console.log(err);
        } else {
            let images=JSON.parse(variant.thumbnail);
            for(let i=0;i<images.length;i++){
                if(images[i]==req.params.image_name){
                    images[i]=req.files[0].filename;
                }
            }
            variant.thumbnail=JSON.stringify(images);
            sharp(req.files[0].path).resize(300).toFile("/gaurang/Parth's workspace/ssm/Admin/src/assets/Images/list_image/"+req.files[0].filename,(err,info)=>{
                if(err){
                    console.log(err);
                } else {
                    let images=JSON.parse(variant.list_image);
                    for(let i=0;i<images.length;i++){
                        if(images[i]==req.params.image_name){
                            images[i]=req.files[0].filename;
                        }
                    }
                    variant.list_image=JSON.stringify(images);
                    // console.log(variant)
                    sharp(req.files[0].path).resize(500).toFile("/gaurang/Parth's workspace/ssm/Admin/src/assets/Images/view_image/"+req.files[0].filename,(err,info)=>{
                        if(err){
                            console.log(err);
                        } else {
                            let images=JSON.parse(variant.view_image);
                            for(let i=0;i<images.length;i++){
                                if(images[i]==req.params.image_name){
                                    images[i]=req.files[0].filename;
                                }
                            }
                            variant.view_image=JSON.stringify(images);
                
                            sql="update product_variants set thumbnail='"+variant.thumbnail+"', list_image='"+variant.list_image+"',view_image='"+variant.view_image+"' where variant_id="+variant.variant_id;
                            con.query(sql,(err,result)=>{
                                if(err) {
                                    console.log(err);
                                } else {
                                    res.send(req.files);
                                }
                            });
                        }
                    });
                }
            });
        }
    });
    
    
}); 

router.get('/getVariant/:variant_id',verifyToken,(req,res)=>{
    let sql="select * from product_variants where variant_id="+req.params.variant_id;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    });
});

router.get('/getAllProducts/:up',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    up=req.params.up;
    let sql="select p.*,c.category_id,c.name as cname from product p, product_category pc,category c where pc.product_id=p.product_id and pc.category_id=c.category_id and  p.user_id="+payload.subject+" order by p.product_id limit "+up+","+limit;

    con.query(sql,(err,products)=>{
        if(err) {
            console.log(err);
        } else {
            let response=new Array();
            response.push(products);
            sql="select * from product_variants where parent=1 and user_id="+payload.subject+" and product_id in(";
            for(let i=0;i<products.length;i++){
                if(i==0){
                    sql=sql+products[i].product_id;
                } else {
                    sql=sql+","+products[i].product_id;
                }
            }
            
            sql=sql+") order by product_id";
            con.query(sql,(err,variants)=>{
                if(err){
                    console.log(err);
                } else {
                    response.push(variants);
                    res.status(200).json(response);
                }
            })
        }
    });
});

router.get('/countAllProduct',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select count(*) as totalProduct from product where user_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    });
});

router.post('/addProduct',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let product=req.body;
    let sql="insert into product(description,display,specifications,user_id) values('"+product.description+"',"+product.display+",'"+product.specifications+"',"+payload.subject+")";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            sql="select max(product_id) as product_id from product where user_id="+payload.subject;
            con.query(sql,(err,product_id)=>{
                if(err) {
                    console.log(err);
                } else {
                    sql="insert into product_category values("+product_id[0].product_id+","+product.category_id+")";
                    con.query(sql,(err,category)=>{
                        if(err) {
                            console.log(err);
                        } else {
                            res.status(200).json({success:true,message:"Product added successfully",product_id:product_id[0].product_id});
                        }
                    });
                }
            });
        }
    });
});

router.put('/updateProduct',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let product=req.body;
    let sql='update product set description="'+product.description+'" where product_id='+product.product_id;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            sql="update product_category set category_id="+product.category_id+" where product_id="+product.product_id;
            con.query(sql,(err,result)=>{
                if(err) {
                    console.log(err);
                } else {
                    res.status(200).json({success:true,message:"Product updated successfully"});
                }
            });
        }
    });
});

function updateAttributes(variant,product_id){
    let sql="select * from product where product_id="+product_id;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            
            let attributes=JSON.parse(result[0].specifications);
            let color=attributes.Color;
            color[variant.color_id]=variant.color;
            attributes.Color=color;
            let size=attributes.Size;
            size[variant.size_id]=variant.size;
            attributes.Size=size;
            sql="update product set specifications='"+JSON.stringify(attributes)+"' where product_id="+product_id;
            con.query(sql,(err,product)=>{
                if(err) {
                    console.log(err);
                } else {
                    return;
                }
            });
        }
    });
}

router.post('/addVariant',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let variant=req.body;
    if(variant.isActive===1){
        sql="update product_variants set parent=0 where product_id="+variant.variant_id;
        con.query(sql,(err,result)=>{
            if(err) {
                console.log(err);
            } else {
                let sql='insert into product_variants(product_id,user_id,name,price,discounted_price,quantity,size_id,color_id,parent,large_image,thumbnail,list_image,view_image) values('+variant.variant_id+','+payload.subject+',"'+variant.name+'",'+variant.price+','+variant.discount+','+variant.quantity+','+variant.size_id+','+variant.color_id+','+variant.isActive+',"[]","[]", "[]","[]")';
                con.query(sql,(err,result)=>{
                    if(err) {
                        console.log(err);
                    } else {
                        updateAttributes(variant,variant.variant_id);
                        let response= getVariants(variant.variant_id);
                        response.then((val)=>{
                            res.status(200).json(val);
                        });
                    }
                });
            }
        })
    } else {
        let sql='insert into product_variants(product_id,user_id,name,price,discounted_price,quantity,size_id,color_id,parent,large_image,thumbnail,list_image,view_image) values('+variant.variant_id+','+payload.subject+',"'+variant.name+'",'+variant.price+','+variant.discount+','+variant.quantity+','+variant.size_id+','+variant.color_id+','+variant.isActive+',"[]","[]","[]","[]")';
        con.query(sql,(err,result)=>{
            if(err) {
                console.log(err);
            } else {
                updateAttributes(variant,variant.variant_id);
                let response= getVariants(variant.variant_id);
                response.then((val)=>{
                    res.status(200).json(val);
                });
            }
        });
    }
    
});

router.put('/updateVariant',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let variant=req.body;
    let sql='update product_variants set name="'+variant.name+'", price='+variant.price+', discounted_price='+variant.discount+',quantity='+variant.quantity+',parent='+variant.isActive+',size_id='+variant.size_id+',color_id='+variant.color_id+' where variant_id='+variant.variant_id;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            let response=getVariants(variant.product_id);
            response.then((val)=>{
                res.status(200).json(val);
            });
        }
    });
});

router.get('/getProductsByDepartment/:up/:department_id',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let up=req.params.up;
    let department_id=req.params.department_id;
    let sql="select p.*,c.category_id,c.name as cname from product p, product_category pc,category c ,department d where pc.product_id=p.product_id and pc.category_id=c.category_id and d.department_id="+department_id+" and c.department_id=d.department_id and  p.user_id="+payload.subject+" order by p.product_id limit "+up+","+limit;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            let response=new Array();
            response.push(result);
            sql="select * from product_variants where parent=1 and product_id in(";
            for(let i=0;i<result.length;i++){
                if(i==0){
                    sql=sql+result[i].product_id;
                } else {
                    sql=sql+","+result[i].product_id;
                }
            }
            sql=sql+")";
            con.query(sql,(err,products)=>{
                if(err) {
                    console.log(err);
                } else {
                    response.push(products);
                    res.status(200).json(response);
                }
            });
        }
    });
});

router.get('/countProductsByDepartments/:department_id',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let department_id=req.params.department_id;
    let sql="select count(p.product_id) as totalProduct from product p,product_category pc,category c, department d where p.user_id="+payload.subject+" and p.product_id=pc.product_id and pc.category_id=c.category_id and c.department_id=d.department_id and d.department_id="+department_id;
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
            res.status(200).json(result);
        }
    });
});

router.get('/searchProduct/:key/:up',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let up=req.params.up;
    let key=req.params.key;
    let sql='select count(*) as totalProduct from product_variants where parent=1 and user_id='+payload.subject+' and name like "%'+ key+'%"';
    con.query(sql,(err,count)=>{
        if(err){
            console.log(err);
        } else {
            let response=new Array();
            response.push(count);
            sql='select * from product_variants where parent=1 and user_id='+payload.subject+' and name like "%'+ key+'%" order by product_id limit '+up+','+limit;
            con.query(sql,(err,variants)=>{
                if(err){
                    console.log(err);
                } else {
                    response.push(variants);
                    if(variants.length>0){
                        sql="select p.*,c.category_id,c.name as cname from product p,category c, product_category pc where p.product_id=pc.product_id and pc.category_id=c.category_id and p.product_id in(";
                        for(let i=0;i<variants.length;i++){
                            if(i==0){
                                sql=sql+variants[i].product_id;
                            } else {
                                sql=sql+','+variants[i].product_id;
                            }
                        }
                        sql=sql+')';
                        con.query(sql,(err,products)=>{
                            if(err) {
                                console.log(err);
                            } else {
                                response.push(products);
                                res.status(200).json(response);
                            }
                        });
                    } else {
                        res.status(200).json(response)
                    }
                    
                }
            });
        }
    });
});

router.get('/getAllValuesForAddProduct',verifyToken,(req,res)=>{
    let sql="select * from category";
    con.query(sql,(err,categories)=>{
        if(err) {
            console.log(err);
        } else {
            let response=new Array();
            response.push(categories);
            sql="select av.* from attribute_value av,attribute a where av.attribute_id=a.attribute_id and a.name='Size'";
            con.query(sql,(err,sizes)=>{
                response.push(sizes);
                sql="select av.* from attribute_value av,attribute a where av.attribute_id=a.attribute_id and a.name='Color'";
                con.query(sql,(err,colors)=>{
                    if(err) {
                        console.log(err);
                    } else {
                        response.push(colors);
                        res.status(200).json(response);
                    }
                });
            });
        }
    });
});

router.get('/getVariants/:product_id',verifyToken,(req,res)=>{
    let product_id=req.params.product_id;
    let response= getVariants(product_id);
    response.then((val)=>{
        res.status(200).json(val);
    });
    
});

async function getVariants(product_id){
    let sql="select p.*,c.category_id,d.department_id from product p,product_category pc,category c,department d where p.product_id=pc.product_id and pc.category_id=c.category_id and c.department_id=d.department_id and p.product_id="+product_id;
    return new Promise((resolve,reject)=>{
        con.query(sql,(err,products)=>{
            if(err){
                console.log(err);
            } else {
                let response=new Array();
                response.push(products);
                sql="select * from  product_variants where product_id="+product_id;
                con.query(sql,(err,variants)=>{
                    if(err) {
                        console.log(err);
                    } else {
                        response.push(variants);
                        resolve(response);
                    }
                });
            }
        })
    }) 
    
}
module.exports=router;