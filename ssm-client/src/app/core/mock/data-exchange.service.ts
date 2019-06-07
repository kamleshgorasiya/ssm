import { Injectable, Output } from '@angular/core';
import { Subject } from 'rxjs';
import { User } from '../data/user';
import { Product } from '../data/product';
import { EventEmitter } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class DataExchangeService {

  /* Service for data interaction among components */

  private messageSource=new Subject<number>();
  private userName=new Subject<User>();
  private addCart=new Subject<string>();
  private addWishlist=new Subject<string>();
  private searchItem=new Subject<string>();
  private addressItem=new Subject<string>();
  private productData=new Subject<Product>();
  private footerFlag=new Subject<boolean>();
  footerRest:EventEmitter<any>=new EventEmitter();

  userMessage$=this.userName.asObservable();
  currentmessage$=this.messageSource.asObservable();
  addCartMessage$=this.addCart.asObservable();
  addWishlistMessage$=this.addWishlist.asObservable();
  searchMessage$=this.searchItem.asObservable();
  addressMessage$=this.addressItem.asObservable();
  productMessage$=this.productData.asObservable();
  footerMessage$=this.footerFlag.asObservable();

  constructor() { }

  /* Functions for changing observable's data */ 

  changeCategory(categoryId){
    this.messageSource.next(categoryId);
  }

  changeUserName(user){
    this.userName.next(user);
  }

  changeCartData(cartData){
    this.addCart.next(cartData);
  }

  changeWishlistData(wishlistData){
    this.addWishlist.next(wishlistData);
  }

  changeSearchData(searchData){
    this.searchItem.next(searchData);
  }

  changeAddress(address){
    this.addressItem.next(address);
  }

  changeProduct(product){
    this.productData.next(product);
  }

  changeFooterFlag(flag){
    this.footerFlag.next(flag);
  }



}
