import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProductDetailComponent } from './product-detail/product-detail.component';
import { ProductsComponent } from './products/products.component';
import { SearchProductComponent } from './search-product/search-product.component';
import { CategoryProductComponent } from './category-product/category-product.component';
import { PagesModule } from '../pages.module';
import { RouterModule } from '@angular/router';


@NgModule({
  declarations: [ProductsComponent,ProductDetailComponent, SearchProductComponent, CategoryProductComponent],
  imports: [
    CommonModule,
    RouterModule
  ],
  exports:[ProductDetailComponent,ProductsComponent,SearchProductComponent]
})
export class ProductModule { }
