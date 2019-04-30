import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class ProductService {

  private allProductUrl="http://localhost:3000/product/allProducts";
  private getAttributesUrl="http://localhost:3000/product/getAttributes";
  private countProductsUrl="http://localhost:3000/product/countProduct";
  private productByCategoryUrl="http://localhost:3000/product/productByCategory";
  private countByCategoryUrl="http://localhost:3000/product/countByCategory";
  private productByIdUrl="http://localhost:3000/product/productById";
  private getProductByNameUrl="http://localhost:3000/product/getProductByName";

  constructor(private _http:HttpClient,private _authService:AuthService) { }
  
  getProducts(limit){
    return this._http.post<any>(this.allProductUrl,limit);
  }
  getAttributes(product){
    return this._http.post<any>(this.getAttributesUrl,product);
  }
  countProducts(){
    return this._http.get<any>(this.countProductsUrl);
  }
  getProductByCategory(category){
    return this._http.post<any>(this.productByCategoryUrl,category);
  }
  countByCategory(category){
    return this._http.post<any>(this.countByCategoryUrl,category);
  }
  getProductById(product){
    return this._http.post<any>(this.productByIdUrl,product);
  }
  getProductByName(product){
    return this._http.post<any>(this.getProductByNameUrl,product);
  }
}
