import { NgModule } from '@angular/core';
import { Routes, RouterModule, ChildActivationEnd } from '@angular/router';
import { LayoutComponent } from '../theme/layout/layout.component';
import { LoginComponent } from './authentication/login/login.component';
import { CategoryListComponent } from './category/category-list/category-list.component';
import { AttributeListComponent } from './attribute/attribute-list/attribute-list.component';
import { ManageAttributeComponent } from './attribute/manage-attribute/manage-attribute.component';
import { ProductDashboardComponent } from './product/product-dashboard/product-dashboard.component';
import { AddProductComponent } from './product/add-product/add-product.component';
import { ProductImageComponent } from './product/product-image/product-image.component';
import { ManageOrderComponent } from './manage-order/manage-order/manage-order.component';


const routes: Routes = [
  {
    path:'',
    component:LoginComponent,
    
  },
  {
    path:'dashboard',
    component:LayoutComponent,
    children:[
      {
        path:'',
        component:CategoryListComponent
      },
      {
        path:'manage-category',
        component:CategoryListComponent
      },
      {
        path:'manage-attributes',
        component:ManageAttributeComponent
      },
      {
        path:'manage-attributes-value',
        component:AttributeListComponent
      },
      {
        path:'manage-products',
        component:ProductDashboardComponent
      },
      {
        path:'add-product',
        component:AddProductComponent 
      },
      {
        path:'edit-product/:id',
        component:AddProductComponent
      },
      {
        path:'add-image/:id',
        component:ProductImageComponent
      },
      {
        path:'manage-orders',
        component:ManageOrderComponent
      }
    ]
  }
  
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class PagesRoutingModule { }
