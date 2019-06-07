import { TestBed,async,inject } from '@angular/core/testing';

import { CartService } from './cart.service';
import { HttpTestingController, HttpClientTestingModule } from '@angular/common/http/testing';
import { HeaderSetter } from '../data/header-setter';

describe('CartService', () => {
  beforeEach(() => TestBed.configureTestingModule({
    imports:[HttpClientTestingModule],
    providers:[HeaderSetter]
  }));

  it(`should create`, async(inject([HttpTestingController, CartService],
    (cartService: CartService) => {
      expect(cartService).toBeTruthy();
  })));
});
