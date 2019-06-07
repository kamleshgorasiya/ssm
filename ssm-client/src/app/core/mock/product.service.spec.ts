import { TestBed,async,inject } from '@angular/core/testing';

import { ProductService } from './product.service';
import { HttpTestingController, HttpClientTestingModule } from '@angular/common/http/testing';
import { HeaderSetter } from '../data/header-setter';

describe('ProductService', () => {
  beforeEach(() => TestBed.configureTestingModule({
    imports:[HttpClientTestingModule],
    providers:[HeaderSetter]
  }));

  it(`should create`, async(inject([HttpTestingController, ProductService],
    (productService: ProductService) => {
      expect(productService).toBeTruthy();
  })));
});
