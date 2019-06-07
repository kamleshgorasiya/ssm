import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from './auth.service';
import { HeaderSetter } from '../data/header-setter';

@Injectable({
  providedIn: 'root'
})
export class ProductService {

   /* Urls of all Product related apis  */

  private allProductUrl=this.headerSetter.baseUrl+"/product/allProducts";
  private getAttributesUrl=this.headerSetter.baseUrl+"/product/getAttributes";
  private countProductsUrl=this.headerSetter.baseUrl+"/product/countProduct";
  private productByCategoryUrl=this.headerSetter.baseUrl+"/product/productByCategory";
  private countByCategoryUrl=this.headerSetter.baseUrl+"/product/countByCategory";
  private productByIdUrl=this.headerSetter.baseUrl+"/product/productById";
  private getProductByNameUrl=this.headerSetter.baseUrl+"/product/getProductByName";
  private getProductByIdsUrl=this.headerSetter.baseUrl+"/product/getProductByIds";
  private getProductCountByNameUrl=this.headerSetter.baseUrl+"/product/countProductByName";
  private getVariantsUrl=this.headerSetter.baseUrl+"/product/getVariants";

  constructor(private _http:HttpClient,private headerSetter:HeaderSetter) { }

  /* Call api for getting all product start from upper bound  */
  
  getProducts(limit){
    return this._http.get<any>(this.allProductUrl+"/"+limit.up);
  }

  /* Call api for getting attributes of products */

  getAttributes(product){
    return this._http.post<any>(this.getAttributesUrl,product);
  }

  /* Call api for counting total number of products */

  countProducts(){
    return this._http.get<any>(this.countProductsUrl);
  }

  /* Call api for getting products according to provided category */

  getProductByCategory(category){
    return this._http.get<any>(this.productByCategoryUrl+"/"+category.categoryId+"/"+category.up);
  }

  /* Call api for counting products of perticular category */

  countByCategory(category){
    return this._http.get<any>(this.countByCategoryUrl+"/"+category.categoryId);
  }

  /* Call api for getting product by id of product */

  getProductById(product){
    return this._http.get<any>(this.productByIdUrl+"/"+product.product_id);
  }

  /* Call api for getting product by name of product */

  getProductByName(product){
    return this._http.get<any>(this.getProductByNameUrl+"/"+product.name+"/"+product.bound);
  }

  /* Call api for gettig products of provided ids */

  getProductsByIds(product){
    return this._http.get<any>(this.getProductByIdsUrl+"/"+product.ids);
  }

  /* Call api for counting records of search records */

  getProductCountByName(product){
    return this._http.get<any>(this.getProductCountByNameUrl+"/"+product.name);
  }
   /* Call api for getting product variants by product id */
   
  getVariants(product){
    return this._http.get<any>(this.getVariantsUrl+"/"+product.product_id);
  }
}
