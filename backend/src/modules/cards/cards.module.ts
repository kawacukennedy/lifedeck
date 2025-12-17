import { Module } from '@nestjs/common';
import { CardsService } from './cards.service';
import { CardsController } from './cards.controller';
import { AchievementsModule } from '../achievements/achievements.module';

@Module({
  controllers: [CardsController],
  providers: [CardsService],
  exports: [CardsService],
  imports: [AchievementsModule],
})
export class CardsModule {}