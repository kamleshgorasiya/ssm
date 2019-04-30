import { Component, OnInit, Pipe } from '@angular/core';
import { ProductService } from 'src/app/core/mock/product.service';
import { Product } from 'src/app/core/data/product';
import { ConcatSource } from 'webpack-sources';
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
  productData:Product[];
  allProduct:CartProduct[]=new Array();
  price;
  count;

  constructor(private _productService:ProductService,
              private _dataExchangeService:DataExchangeService,
              private _cartService:CartService,
              private _router:Router,
              private _authService:AuthService) { }

  ngOnInit() {
    if(!this._authService.loggedIn()){
      this._router.navigate(['']);
    }
    this._cartService.getCartProducts()
    .subscribe(
      res=>{
        this.cartData=res[0]; 
        this.productData=res[1];
        let size;
        let total:number,discount:number,net:number;
        total=discount=net=0;
        for(let i=0;i<this.cartData.length;i++){
          for(let j=0;j<this.productData.length;j++){
            if(this.cartData[i].product_id==this.productData[j].product_id){
              size=JSON.parse(this.cartData[i].attributes);
              let product:CartProduct={
                item_id:this.cartData[i].item_id,
                name:this.productData[j].name,
                price:this.productData[j].price.toString(),
                discounted_price:this.productData[j].discounted_price.toString(),
                actual_price:this.productData[j].price,
                actual_discount:this.productData[j].discounted_price,
                quantity:this.cartData[i].quantity,
                size:size.Size,
                color:size.Color,
                image:this.productData[j].image
              };
              total=total+this.productData[j].price+this.productData[j].discounted_price;
              discount=discount+this.productData[j].discounted_price;
              this.allProduct.push(product);
            }
          }
        }
        this.count=this.allProduct.length;
        net=total-discount;
        this.price={
          total:total.toFixed(2).toString(),
          discount:discount.toFixed(2).toString(),
          net:net.toFixed(2).toString()
        }
      }
    )
  }
  
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
      total:total.toFixed(2).toString(),
      discount:discount.toFixed(2).toString(),
      net:net.toFixed(2).toString()
    }
  }

  calculateItemPrice(index){
    let cart={
      item_id:this.allProduct[index].item_id,
      quantity:this.allProduct[index].quantity
    }
    this._cartService.updateQuantity(cart)
    .subscribe(
      res=>{

      },
      err=>{
        console.log("Quantity not updated");
      }
    )
    let price:number,discount:number;
    price=this.allProduct[index].quantity*this.allProduct[index].actual_price;
    this.allProduct[index].price=price.toFixed(2);
    discount=this.allProduct[index].quantity*this.allProduct[index].actual_discount;
    this.allProduct[index].discounted_price=discount.toFixed(2);
    this.calculatePrice();
  }
  incrementQuantity(index){
    this.allProduct[index].quantity=this.allProduct[index].quantity+1;
    this.calculateItemPrice(index);
  }
  decrementQuantity(index){
    this.allProduct[index].quantity=this.allProduct[index].quantity-  1;
    this.calculateItemPrice(index);
    
  }
  removeCart(item_id){
   let cart={item_id:item_id};
   this._cartService.removeCart(cart)
   .subscribe(
     res=>{
      this.allProduct=this.allProduct.filter(item=>item.item_id!==item_id);
      this._dataExchangeService.changeCartData("added");
      this._dataExchangeService.changeWishlistData("addeed");
      this.calculatePrice();
      this.count=this.allProduct.length;
     }
   )
  }
  moveToWishList(item_id){
    let cart={item_id:item_id};
    this._cartService.moveToWishlist(cart)
    .subscribe(
      res=>{
        this.allProduct=this.allProduct.filter(item=>item.item_id!==item_id);
        this._dataExchangeService.changeCartData("added");
        this._dataExchangeService.changeWishlistData("addeed");
        this.calculatePrice();
        this.count=this.allProduct.length;
      },
      err=>{
        window.alert("Cart is not moved to Wishlist")
      }
    )
  }
  placeOrder(){
    this._router.navigate(['address']);
  }
}
