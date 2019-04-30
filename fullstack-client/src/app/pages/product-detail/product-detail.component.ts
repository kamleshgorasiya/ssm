import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Product } from 'src/app/core/data/product';
import { ProductService } from 'src/app/core/mock/product.service';
import { AuthService } from 'src/app/core/mock/auth.service';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { JsonPipe } from '@angular/common';
import { CartService } from 'src/app/core/mock/cart.service';

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
              private _cartService:CartService) { }
  product:Product;
  sizeError="";
  colorError="";
  attributes;
  sizes=new Array();
  colors=new Array();
  image;
  wishlist;
  selectedSize="";
  selectedColor="";
  images=new Array();
  display_images=new Array();
  ngOnInit() {

    this._route.params.subscribe(
      params=>{
       let product={'product_id':params.id};
       this.productService.getProductById(product)
       .subscribe(
         res=>{
           this.product=res[0];
           this.image=this.product.image;
           this.attributes=this.product.attributes;
           this.attributes=JSON.parse(this.attributes);
           let s=this.attributes.Size;
           
           let keys=Object.keys(s);
           for(let i=0;i<keys.length;i++){
           let key=keys[i];
            this.sizes[i]=s[key];
          }
          s=this.attributes.Color;
          keys=Object.keys(s);
           for(let i=0;i<keys.length;i++){
           let key=keys[i];
            this.colors[i]=s[key];
          }
         },
         err=>{
           console.log(err);
         }
       )
         this._cartService.getWishlistProduct()
         .subscribe(
           res=>{
             let products=res[1];
             if(products.length>0){
              for(let i=0;i<products.length;i++){
                if(products[i].product_id==product.product_id){
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
      }
    )
  }
  changeImage(image){
    this.image=image;
  }

  changeSize(size){
    this.selectedSize=size;
    this.sizeError="";
  }

  changeColor(color){
    this.selectedColor=color;
    this.colorError=""
  }

  addToBag(){
    if(this.selectedSize==""){
      this.sizeError="Please select size";
      
    } else {
      if(this.selectedColor==""){
        this.colorError="Please select Color";
      } else {
        let attribute={
          Size:this.selectedSize,
          Color:this.selectedColor
        };
        let attr=JSON.stringify(attribute);
        let cart={
          product_id:this.product.product_id,
          attributes:attr,
          quantity:1
        }
        if(!this.authService.loggedIn()){
          let count=localStorage.getItem("cart");
          let cartData=new Array();
          if(count!=null){
            cartData=JSON.parse(count);
            cartData.push(cart);
            localStorage.setItem("cart",JSON.stringify(cartData));
          } else {
            cartData.push(cart);
            localStorage.setItem("cart",JSON.stringify(cartData));
          }
        }else{
          if(this.wishlist=="WISHLISTED"){
            console.log("dsa")
            this._cartService.addToBagWishList(cart)
            .subscribe(
              res=>{
                this._dataExchangeService.changeCartData("added");
                this._dataExchangeService.changeWishlistData("added");
              }
            )
          } else {
            this._cartService.addToBag(cart)
            .subscribe(
              res=>{
                window.alert(res.message);
                this._dataExchangeService.changeCartData("added")
              }
            )
          }
        }
        this._dataExchangeService.changeCartData("added");
        
      }
    }
  }

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
              window.alert(res.message);
              this._router.navigate(['']);
              this._dataExchangeService.changeWishlistData("added");
            }
          )
        }
        
      
  
  }
}
