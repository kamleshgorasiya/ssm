import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Product } from 'src/app/core/data/product';
import { ProductService } from 'src/app/core/mock/product.service';
import { AuthService } from 'src/app/core/mock/auth.service';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { CartService } from 'src/app/core/mock/cart.service';
import { IterableChangeRecord_ } from '@angular/core/src/change_detection/differs/default_iterable_differ';


@Component({
  selector: 'app-product-detail',
  templateUrl: './product-detail.component.html',
  styleUrls: ['./product-detail.component.css']
})
export class ProductDetailComponent implements OnInit {

  constructor(private _route:ActivatedRoute,
              private productService:ProductService,
              private authService:AuthService,
              private _router:Router,
              private _dataExchangeService:DataExchangeService,
              private _cartService:CartService) {
               }

  // Declaration section of global variables

  product=new Product();
  sizes=new Array();
  colors=new Array();
  variants=new Array();
  products=new Array();
  attribute=new Array();
  display_images=new Array();
  sizeError="";
  colorError="";
  attributes;
  image="";
  err=0;
  imageCounter=0;
  wishlist;
  selectedSize="";
  selectedColor="";
  images;
  
  // function for checking string is json or not

  isJson(str):boolean {
    try {
        JSON.parse(str);
    } catch (e) {
        return false;
    }
    return true;
  }

  // prepare the content for display product

  setContent(){
        
    this.attributes=this.product.attributes;
    let variant=this.variants.find(item=>item.variant_id==this.product.product_id)
    let size;
    delete this.sizes;
    delete this.colors;
    this.colors=new Array();
    this.sizes=new Array();
    for(let i=0;i<this.variants.length;i++){
      if(this.variants[i].color_id==variant.color_id){
        size=this.attribute.find(item=>item.attribute_value_id==this.variants[i].size_id);
        this.sizes.push({"size":size.value,"quantity":this.variants[i].quantity})
      }
      
      this.colors.push(this.variants[i].color_id);
    }
    let color=Array.from(new Set(this.colors));
    delete this.colors;
    this.colors=new Array();
    for(let i=0;i<color.length;i++){
      size=this.variants.find(item=>item.color_id==color[i]);
      this.colors.push(size);
      if(this.isJson(this.colors[i].thumbnail)){
        this.colors[i].thumbnail=JSON.parse(this.colors[i].thumbnail);
      }
    }

  // if user is logged in, it will check that product is in wishlist of user or not
    
  if(this.authService.loggedIn()){
    this._cartService.getWishlistProduct()
    .subscribe(
      res=>{
        let products=res[1];
        if(products.length>0){
         for(let i=0;i<products.length;i++){
           if(products[i].product_id==this.product.product_id){
             this.wishlist="WISHLISTED";
             break;
           } else {
             this.wishlist="ADD TO WISHLIST";
           }
         }
        } else {
          this.wishlist="ADD TO WISHLIST";
        }
      }
    )
   } else {
     this.wishlist="ADD TO WISHLIST";
   }
   this.images=JSON.parse(this.product.image);
    this.image=this.images[0];
    if(this.isJson(this.product.thumbnail)){
      this.images=JSON.parse(this.product.thumbnail);
    }
    localStorage.removeItem("product")
  }

  // Prepaere the product data for displaying detail 

  setProduct(tempProduct:any){
    tempProduct=this.variants.find(item=>item.variant_id==tempProduct.variant_id)
    let product=new Product();
      product={
      product_id:tempProduct.variant_id,
      name:tempProduct.name,
      description:this.products[0].description,
      display:this.products[0].display,
      price:tempProduct.price,
      discounted_price:tempProduct.discounted_price+tempProduct.price,
      image:tempProduct.view_image,
      thumbnail:tempProduct.thumbnail,
      attributes:this.products[0].specifications,
      image_2:"" 
    }
    this.product=product;
    if(this.product==null){
      this.product=new Product();
    } else {
    }
    this.setContent();
  }


  ngOnInit() {

    let id;
    this._route.params.subscribe(
      params=>{
        id=params.id;
      }
    )

    // Getting product's detail form localstorage

    this.product=JSON.parse(localStorage.getItem("product"));
    
    // If localstorage don't have product data it will get from server

    if(this.product==null){
      let product={'product_id':id};
      this.productService.getProductById(product)
      .subscribe(
        res=>{
            this.variants=res[0];
            this.products=res[1];
            this.attribute=res[2];
            let p1=this.variants.find(item=>item.variant_id==id);
            this.setProduct(p1);
        }
      )
    } else {

      // If localstorage have a product data, it will get only variants of that products and attributes from server

      let product={'product_id':id};
      this.products[0]=this.product;
      this.productService.getVariants(product)
      .subscribe(
        res=>{
          this.variants=res[0];
          this.attribute=res[1];
          this.setContent();
        }
      )
     
    }
  }

  // Function for change Main View Image

  changeImage(image){
    this.image=image;
  }

  // Function for changing size of product

  changeSize(size){
    this.selectedSize=size;
    this.sizeError="";
  }

  // Function for changing main image when hover the color

  hoverColor(color){
    let img=JSON.parse(color.view_image);
    this.image=img[0];
  }

  // Function for set default image to main image when hover leave from color

  leaveColor(color){
   let img=JSON.parse(this.product.image);
    this.image=img[0];
  }

  // Function for change product data when user change the color

  changeColor(color){
    this.selectedColor=color.variant_id;
    this.colorError=""
    this.setProduct(color);
  }


  /*
    * Add a product to cart in database if user is logged in and authenticated.
    * If user is not logged in, it will store the data in localstorage
  */ 

  addToBag(){
    if(this.selectedSize==""){
      this.sizeError="Please select size";
      this.err=1;
    } else {
      if(this.selectedColor==""){
        this.colorError="Please select Color";
      } else {

        let product=this.variants.find(item=>item.variant_id==this.selectedColor);
        let color=this.attribute.find(item=>item.attribute_value_id==product.color_id);

        let attribute={
          Size:this.selectedSize,
          Color:color.value
        };

        let size=this.attribute.find(item=>item.value==this.selectedSize);
        let productid=this.variants.find(item=>item.size_id==size.attribute_value_id && item.color_id==product.color_id);
        this.product.product_id=productid.variant_id;
        let attr=JSON.stringify(attribute);
        let cart={
          product_id:this.product.product_id,
          attributes:attr,
          quantity:1
        }
        if(!this.authService.loggedIn()){

          // if user is not logged in,it will store product to localstorage cart of user

          let count=localStorage.getItem("cart");
          let cartData=new Array();
          if(count!=null){
            let test=0;
            let attributes;
            cartData=JSON.parse(count);
            for(let i=0;i<cartData.length;i++){
              if(cartData[i].product_id==cart.product_id && cartData[i].attributes==cart.attributes){
                test=1;
              }
            }
            if(test==0){
              cartData.push(cart);
              localStorage.setItem("cart",JSON.stringify(cartData));
            }
          } else {
            cartData.push(cart);
            localStorage.setItem("cart",JSON.stringify(cartData));
          }
        }else{

          // if product is already in wishlist,it will remove from wishlist and adding in cart

          if(this.wishlist=="WISHLISTED"){
            this._cartService.addToBagWishList(cart)
            .subscribe(
              res=>{
                window.alert("Product is added to cart successfully from wishlist");
                this._dataExchangeService.changeCartData("added");
                this._dataExchangeService.changeWishlistData("added");
              }
            )
          } else {

            // it will add product to cart 

            this._cartService.addToBag(cart)
            .subscribe(
              res=>{
                this._dataExchangeService.changeCartData("added")
                window.alert(res[0].message)
              },
              err=>{
                console.log("Product is not added to Bag")
              }
            )
          }
        }
        this._dataExchangeService.changeCartData("added");
        
      }
    }
  }

  // add a product to wishlist if user is logged in.

  addToWishlist(){
    let wishlist={
      product_id:this.product.product_id,
      quantity:1
    }
    if(!this.authService.loggedIn()){
      this._router.navigate(['/login']);

    } else {
      this._cartService.addToWishlist(wishlist)
      .subscribe(
        res=>{
          this._router.navigate(['']);
          this._dataExchangeService.changeWishlistData("added");
        }
      )
    }
  }

}
