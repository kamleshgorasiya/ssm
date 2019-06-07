import { Component, OnInit } from '@angular/core';
import { ProductService } from 'src/app/core/mock/product.service';
import { Product } from 'src/app/core/data/product';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { CartProduct } from 'src/app/core/data/cart-product';
import { CartService } from 'src/app/core/mock/cart.service';
import { Router } from '@angular/router';
import { AuthService } from 'src/app/core/mock/auth.service';

@Component({
  selector: 'app-cart-detail',
  templateUrl: './cart-detail.component.html',
  styleUrls: ['./cart-detail.component.css']
})
export class CartDetailComponent implements OnInit {

  cartData;
  variants;
  products;
  productData:Product[];
  allProduct:CartProduct[]=new Array();
  price={};
  count=0;


  constructor(private _productService:ProductService,
              private _dataExchangeService:DataExchangeService,
              private _cartService:CartService,
              private _router:Router,
              private _authService:AuthService) { }

  ngOnInit() {
    localStorage.removeItem("reference")
    if(this._authService.loggedIn()){

      // Fetch the cart data if user is logged in.

      this._cartService.getCartProducts()
      .subscribe(
        res=>{
          this.cartData=res[0]; 
          this.count=1;
          if(this.cartData.length>0){
            this.variants=res[1];
            this.setItems();
          }
          else {
            this.count=0;
          }
        }
  
      )
    } else {

      // If user is not logged in, it will check for cart data present in local storage

      let localcart=JSON.parse(localStorage.getItem("cart"));
      if(localcart!=null){
        let queryData="(";
        for(let i=0;i<localcart.length;i++){
          if(i==0){
            queryData=queryData+localcart[i].product_id;
          } else {
            queryData=queryData+","+localcart[i].product_id;
          }
        }
        queryData=queryData+")";
        let product={ids:queryData};

      // Fetch product detail by product ids.

        this._productService.getProductsByIds(product)
        .subscribe(
          res=>{
            this.variants=res;
            for(let i=0;i<localcart.length;i++){
              localcart[i].item_id=localcart[i].product_id;
              localcart[i].product_variant_id=localcart[i].product_id;
            }
            this.cartData=localcart;
            this.setItems();
          }
        )
      } else {
        this.count=0;
      }  
    }
  }

  // Prepare the display content.

  setItems(){
    let size;
    let total:number,discount:number,net:number;
    total=discount=net=0;
    let product:CartProduct;
    for(let i=0;i<this.cartData.length;i++){
      for(let j=0;j<this.variants.length;j++){
        if(this.cartData[i].product_variant_id==this.variants[j].variant_id){
          size=JSON.parse(this.cartData[i].attributes);
          let img=JSON.parse(this.variants[j].list_image);
            product={
              item_id:this.cartData[i].item_id,
              name:this.variants[j].name,
              price:this.variants[j].price,
              discounted_price:this.variants[j].discounted_price,
              actual_price:this.variants[j].price,
              actual_discount:this.variants[j].discounted_price,
              quantity:this.cartData[i].quantity,
              size:size.Size,
              color:size.Color,
              image:img[0],
              attributes:this.cartData[i].attributes
            };
            product.price=this.variants[j].price*this.cartData[i].quantity;
            product.discounted_price=(this.variants[j].discounted_price*this.cartData[i].quantity)+product.price;
            total=total+product.price;
            discount=discount+product.discounted_price;         
          this.allProduct.push(product);
        }
      }
    }
    this.count=this.allProduct.length;
    total=total+discount;
    net=total-discount;
    this.price={
      total:total,
      discount:discount,
      net:net
    }
   
  }

  // Transfer control to wishlist when there is not product in bag.

  goToWishlist(){
    this._router.navigate(['wishlist'])
  }

  // Calculating total prices, discount,etc. when user changes the quantity

  calculatePrice(){
    let total:number,discount:number,net:number;
    total=discount=net=0;

    for(let i=0;i<this.allProduct.length;i++){
      total=total+this.allProduct[i].actual_price*this.allProduct[i].quantity;
      discount=discount+this.allProduct[i].actual_discount*this.allProduct[i].quantity;
    }

    total=total+discount;
    net=total-discount;

    this.price={
      "total":total.toFixed(2).toString(),
      "discount":discount.toFixed(2).toString(),
      "net":net.toFixed(2).toString()
    }
  }

  // Calculating products price when chages in the quantity.

  calculateItemPrice(index){
    if(this._authService.loggedIn()){
      let cart={
        item_id:this.allProduct[index].item_id,
        quantity:this.allProduct[index].quantity
      }
      this._cartService.updateQuantity(cart)
      .subscribe(
        err=>{
          console.log("Quantity not updated");
        }
      )
    } else {
      let localcart=JSON.parse(localStorage.getItem("cart"));
      localcart[index].quantity=this.allProduct[index].quantity;
      localStorage.setItem("cart",JSON.stringify(localcart));
    }
    let price:number,discount:number;
    price=this.allProduct[index].quantity*this.allProduct[index].actual_price;
    this.allProduct[index].price=price;
    discount=this.allProduct[index].quantity*this.allProduct[index].actual_discount;
    this.allProduct[index].discounted_price=discount+price;
    this.calculatePrice();
  }

  // update the quantity

  updateQuantity(index,count:number){
   
    this.allProduct[index].quantity=this.allProduct[index].quantity+count;
    this.calculateItemPrice(index);
  }
  
  // Removing items from Bag from database or localstorage.

  removeCart(item_id){
    if(this._authService.loggedIn()){
      let cart={item_id:item_id.item_id};
      this._cartService.removeCart(cart)
      .subscribe(
        res=>{
         this.allProduct=this.allProduct.filter(item=>item.item_id!==item_id.item_id);
         this._dataExchangeService.changeCartData("added");
         this._dataExchangeService.changeWishlistData("addeed");
         this.calculatePrice();
         this.count=this.allProduct.length;
        }
      )
    } else {
      let localcart=JSON.parse(localStorage.getItem("cart"));
      let i;
      for(i=0;i<localcart.length;i++){
        if(item_id.item_id==localcart[i].product_id && item_id.attributes==localcart[i].attributes){
          localcart.splice(i,1);
          break;
        }
      }
      localStorage.setItem("cart",JSON.stringify(localcart));
      this.allProduct.splice(i,1);
      this._dataExchangeService.changeCartData("added");
    } 
  }

  // Removing product from bag and adding into wishlist.

  moveToWishList(item_id){
    if(this._authService.loggedIn()){
      let cart={item_id:item_id};
      this._cartService.moveToWishlist(cart)
      .subscribe(
      res=>{
        this.allProduct=this.allProduct.filter(item=>item.item_id!==item_id);
        this._dataExchangeService.changeCartData("added");
        this._dataExchangeService.changeWishlistData("added");
        this.calculatePrice();
        this.count=this.allProduct.length;
      },
      err=>{
        window.alert("Cart is not moved to Wishlist")
      }
    )
    } else {
      localStorage.setItem("reference","cart");
      this._router.navigate(['login']);
    }
  }

  // Go for checkout when user place the order.

  placeOrder(){
    if(this._authService.loggedIn()){
      this._router.navigate(['address']);
    } else {
      localStorage.setItem("reference","cart")
      this._router.navigate(['login']);
    }
  }
}
