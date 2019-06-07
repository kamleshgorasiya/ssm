import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Headersetter } from '../data/headersetter';

@Injectable({
  providedIn: 'root'
})
export class ProductService {

  private service="/product";
  constructor(private _http:HttpClient,
              private _headerSetter:Headersetter) { }
      
  /* All products related APIs Urls declaration */

  private getAllProductUrl=this._headerSetter.baseUrl+this.service+"/getAllProducts";
  private countAllProductUrl=this._headerSetter.baseUrl+this.service+"/countAllProduct";
  private getProductsByDepartmentUrl=this._headerSetter.baseUrl+this.service+"/getProductsByDepartment";
  private countProductsByDepartmentUrl=this._headerSetter.baseUrl+this.service+"/countProductsByDepartments";
  private searchProductUrl=this._headerSetter.baseUrl+this.service+"/searchProduct";
  private getValuesForAddProductUrl=this._headerSetter.baseUrl+this.service+"/getAllValuesForAddProduct";
  private getVariantsUrl=this._headerSetter.baseUrl+this.service+"/getVariants";
  private addProductUrl=this._headerSetter.baseUrl+this.service+"/addProduct";
  private addVariantUrl=this._headerSetter.baseUrl+this.service+"/addVariant";
  private updateVariantUrl=this._headerSetter.baseUrl+this.service+"/updateVariant";
  private updateProductUrl=this._headerSetter.baseUrl+this.service+"/updateProduct"; 
  private uploadImageUrl=this._headerSetter.baseUrl+this.service+"/upload-image";
  private getVariantByIdUrl=this._headerSetter.baseUrl+this.service+"/getVariant";
  private editUploadedImageUrl=this._headerSetter.baseUrl+this.service+"/editImageUpload";


  /* Calls api for getting product data within page limit */
  
  getAllProduct(up){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getAllProductUrl+"/"+up,options);
  }

  /* Calls api for count total Products of specific user */

  countAllProduct(){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.countAllProductUrl,options);
  } 

  /* Calls api for getting products by giving department_id */

  getProductsByDepartment(up,department_id){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getProductsByDepartmentUrl+"/"+up+"/"+department_id,options);
  }

  /* Calls api for count the total products in perticular department */ 

  countProductsByDepartment(department_id){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.countProductsByDepartmentUrl+"/"+department_id,options);
  }

  /* Calls api for getting products by keywords searched by user */
  
  searchProducts(key,up){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.searchProductUrl+"/"+key+"/"+up,options);
  }

  /* Calls api for getting values of category,attributes for add a product purpose */

  getValuesForAddProduct(){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getValuesForAddProductUrl,options);
  }

  /* Calls api for getting variants of particular product */

  getVarinats(product_id){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getVariantsUrl+"/"+product_id,options);
  }

  /*  Calls api for adding common detail of Product */

  addProduct(products){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.addProductUrl,products,options);
  }

  /* Calls api for adding variants of product */

  addVariant(variant){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.addVariantUrl,variant,options);
  }

  /* Calls api for updating the product variant */

  updateVariant(variant){
    let options=this._headerSetter.getHeader();
    return this._http.put<any>(this.updateVariantUrl,variant,options);
  }

  /* Callls api for updaing product common detail */

  updateProduct(product){
    let options=this._headerSetter.getHeader();
    return this._http.put<any>(this.updateProductUrl,product,options);
  }

  /* Calls api for uploading image of variant */

  uploadImage(formdata,variant_id){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.uploadImageUrl+"/"+variant_id,formdata,options);
  }

  /* Calls api for getting variant by its id */

  getVariant(variant_id){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getVariantByIdUrl+"/"+variant_id,options);
  }

  /* Edit the uploaded image */

  editUploadedImage(formdata,variant_id,image_name){
    console.log(image_name);
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.editUploadedImageUrl+"/"+variant_id+"/"+image_name,formdata,options);
  }
}
