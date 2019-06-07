import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProductDashboardComponent } from './product-dashboard/product-dashboard.component';
import { AddProductComponent } from './add-product/add-product.component';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { ProductImageComponent } from './product-image/product-image.component';

@NgModule({
  declarations: [ProductDashboardComponent, AddProductComponent, ProductImageComponent],
  imports: [
    CommonModule,
    FormsModule,
    RouterModule
  ]
})
export class ProductModule { }
