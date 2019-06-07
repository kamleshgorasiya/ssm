import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { PagesRoutingModule } from './pages-routing.module';
import { ThemeModule } from '../theme/theme.module';
import { AuthenticationModule } from './authentication/authentication.module';
import { CategoryModule } from './category/category.module';
import { AttributeModule } from './attribute/attribute.module';
import { ProductModule } from './product/product.module';
import { ManageOrderModule } from './manage-order/manage-order.module';

@NgModule({
  declarations: [],
  imports: [
    CommonModule,
    PagesRoutingModule,
    ThemeModule,
    AuthenticationModule,
    CategoryModule,
    AttributeModule,
    ProductModule,
    ManageOrderModule
  ]
})
export class PagesModule { }
