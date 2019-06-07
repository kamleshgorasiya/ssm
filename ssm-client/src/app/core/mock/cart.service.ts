import { Injectable } from '@angular/core';
import { AuthService } from './auth.service';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { HeaderSetter } from '../data/header-setter';

@Injectable({
  providedIn: 'root'
})
export class CartService {


  /* Urls of all Cart  & Wishlist related apis  */

  private addToWishListUrl=this.headerSetter.baseUrl+"/cart/addToWishList"
  private addLocalBagsUrl=this.headerSetter.baseUrl+"/cart/addLocalBags";
  private getCartProductsUrl=this.headerSetter.baseUrl+"/cart/getCartProducts";
  private moveToWishlistUrl=this.headerSetter.baseUrl+"/cart/moveToWishlist";
  private removeCartUrl=this.headerSetter.baseUrl+"/cart/removeCart";
  private updateQuantityUrl=this.headerSetter.baseUrl+"/cart/updateQuantity";
  private getWishlistProductsUrl=this.headerSetter.baseUrl+"/cart/getWishlistProduct";
  private checkWishListUrl=this.headerSetter.baseUrl+"/cart/checkWishlist";
  private removeWishlistUrl=this.headerSetter.baseUrl+"/cart/removeWishlist";
  private addToBagWishlistUrl=this.headerSetter.baseUrl+"/cart/addToBagWishlist";
  private addToBagUrl=this.headerSetter.baseUrl+"/cart/addToBag";
  
  constructor(private _http:HttpClient,
              private headerSetter:HeaderSetter) { }

  /* Call add to bag api */

  addToBag(cart){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.addToBagUrl,cart,options);
  }

  /* Call api for storing product in wishlist of user */

  addToWishlist(wishlist){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.addToWishListUrl,wishlist,options);
  }

  /* Call api for storing products in cart of uesr from local storage of user */ 

  addLocalBags(products){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.addLocalBagsUrl,products,options);
  }

  /* Call api for getting products in cart of user */

  getCartProducts(){
    let options=this.headerSetter.getHeader();
    return this._http.get<any>(this.getCartProductsUrl,options);
  }

  /* Call api for moving product from cart to wishlist */

  moveToWishlist(cart){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.moveToWishlistUrl,cart,options);
  }

  /* Call api for removing product from cart of user */

  removeCart(cart){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.removeCartUrl,cart,options);
  }

  /* Call api for updating the quantity of product in cart */

  updateQuantity(cart){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.updateQuantityUrl,cart,options);
  }

  /* Call api for getting products in  user wishlist */

  getWishlistProduct(){
    let options=this.headerSetter.getHeader();
    return this._http.get<any>(this.getWishlistProductsUrl,options);
  }

  /* Call api for checking products is in wishlist of user or not */
  
  checkWishlist(wishlist){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.checkWishListUrl,wishlist,options);
  }

  /* Call api for removing products from wishlist of user */

  removeWishlist(wishlist){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.removeWishlistUrl,wishlist,options);
  }

  /* Call api for moving product from wishlist to cart */
  
  addToBagWishList(product){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.addToBagWishlistUrl,product,options);
  }
}
